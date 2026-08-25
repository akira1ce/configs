---
name: new-demo
description: 当我创建一个接口请求组件时，调用该技能
user-invocable: true
---

# 文件结构与职责

- 文件结构模板如下所示

users/ # 页面名称
├── api.ts # Layer 1: 1:1 接口定义
├── service.ts # Layer 2: 数据聚合与组装 [可选]
├── controller.ts # Layer 3: 数据清洗与格式化 (Zod) [可选]
├── types.ts # 类型定义  
├── store.ts # zustand 状态
├── components/ # 内部组件
│ ├── user-filter.tsx # 筛选栏 (简略示意)
│ ├── user-table.tsx # 数据展示 (简略示意)
│ └── action-modal.tsx # 操作弹窗 (简略示意)
└── index.tsx # Layer 4: View 入口

# 参考模板

- types.ts 负责定义类型

```ts types.ts
import { z } from "zod";

// Zod Schema：定义 View 层需要的“完美”数据结构
// Zod 可选，有些项目并不需要前端做数据过多的数据校验
export const UserViewSchema = z.object({
  id: z.string(),
  name: z.string(),
  jobTitle: z.string(),
  hireDate: z.string(), // 格式化后的日期字符串
  status: z.enum(["active", "resigned", "vacation"]),
  statusLabel: z.string(), // 直接用于 UI 展示的文本
  permissionLevel: z.string(),
  avatar: z.string(),
});

export type UserViewModel = z.infer<typeof UserViewSchema>;

// 后端原始接口数据类型 (DTO)
export interface UserDTO {
  uuid: string;
  full_name: string | null;
  position: string;
  created_at: number; // 时间戳
  state: number; // 0: 正常, 1: 离职, 2: 休假
  role_id: number;
}

// 筛选参数类型
export interface ApiGetUsersInfoReq {
  keyword?: string;
  jobTitle?: string;
  hireDateRange?: [string, string];
}

// 操作类型
export type ActionType = "permission" | "resign" | "transfer";
```

- api.ts：负责与后端接口保持 1:1 请求定义，不做额外逻辑处理

```ts api.ts
import { get } from "@/utils/http2";

export async function getUpUsersInfo() {
  const response = await get<{ results: UserInfo[] }>("/api/randomuser/api", {
    cancelPrevious: true,
    params: {
      results: 2,
      inc: "name,gender,email,nat,picture,noinfo",
    },
  });
  return response.results;
}

export async function getDownUsersInfo() {
  const response = await get<{ results: UserInfo[] }>("/api/randomuser/api", {
    cancelPrevious: true,
    params: {
      results: 3,
      inc: "name,gender,email,nat,picture,noinfo",
    },
  });
  return response.results;
}
```

## service.ts：[可选]

- 适用：当一个组件需要多个接口合并数据时使用
- 职责：**聚合数据**，引入 api.ts, 对外导出唯一数据源
- 当多个接口并行时，使用 Promise.all 合并成为一个 Promise

```ts
import { getUpUsersInfo, getDownUsersInfo } from "./api";

export async function getUsersInfo() {
  const results = await Promise.all([getUpUsersInfo(), getDownUsersInfo()]);
  return results[0].concat(results[1]);
}
```

- 当多个接口前后依赖时，使用 await 进行合并

```ts
import { getUpUsersInfo, getDownUsersInfo } from "./api";

// 串行请求：第二个请求依赖第一个请求完成
export async function getUsersInfo() {
  const upResults = await getUpUsersInfo();
  const downResults = await getDownUsersInfo();
  return upResults.concat(downResults);
}
```

## controller.ts`：

- 引入 service.ts 或者 api.ts，将处理好的数据包裹在 Promise 对象中返回
- 职责：**数据加工与清洗**。负责类型验证（Zod）、字段补全、安全校验、格式转换
- 产出：直接对接 View 层，提供符合 UI 需求的完美数据结构

## **View 层 (`index.tsx`)**：

- 职责：纯粹的 UI 渲染。
- 禁忌：禁止在 JSX 中写 `item.desc || ''` 等防御性代码，此类逻辑应在 Controller 完成
- 普通异步组件使用 `useQuery.ts` 请求数据
- 滚动加载更多，使用 `usePagination.ts` 请求数据

```ts
import useQuery from '@/hooks/useQuery';
import { getOverUsersInfo } from './controller';
import List from '@/app/reactplus/ui/list';
import User from './user';

export default function App() {
  const { content, loading, fetching, turnon, error, reInitialize } = useQuery(getOverUsersInfo, {
    foundation: []
  });

  function _inputHandler() {
    turnon()
  }

  return (
    <div className="p-4">
      <input onChange={_inputHandler} placeholder="search member name..." className='w-full border border-stone-200! dark:border-stone-800! p-2' />

      <List
        className='mt-6'
        data={content}
        loading={loading}
        fetching={fetching}
        error={error}
        onRetry={reInitialize}
        skeletonCount={5}
        renderItem={(user, index) => (
          <User key={user.id} user={user} index={index} />
        )}
      />
    </div>
  );
}
```

# 技术栈（可以剥离到全局 rules 中去）

- next.js 16(App router)
- tailwindcss 4
- react 19
- antd 6
-

# 技术细节

- 使用 useQuery.ts 请求接口
- [可选] 接口参数使用 useRef 在入口文件中统一管理
- 做好状态归属，优先在子组件中管理自己内部的状态，使用 value onChange 的方式进行初始化与父子通信
- 如果存在接口数据之外的其他状态需要跨组件传递，使用 zustand 管理
- **单一数据入口**：一个 View（组件）层只应有一个数据获取入口。如果需要多个，应优先拆分组件。
- **拿来即用原则**：View 层不处理任何数据逻辑（如过滤、格式化），数据到达 View 层必须是**最终可用状态**

# 组件拆分标准

1.  **总分总原则**：先明确页面整体形态，再拆分细节，最后组合。
2.  **拆分目的**：核心是为了**提高可读性与可维护性**，而非单单为了复用。
3.  **200 行警戒线**：单个文件代码超过 200 行时，应考虑拆分
4.  **语义化标准**：拆分出的组件必须能提炼出明确的**语义**
5.  **Loading 映射原则**：一个 Loading 状态对应一个完整的异步逻辑组件（无论背后涉及多少个接口）。

# 模块语法

- 使用 `export` 对外导出，不要使用 `export default`
- 使用 `import {} from 'xxx'`，不要使用 `import * as xxx from 'xxx'`
