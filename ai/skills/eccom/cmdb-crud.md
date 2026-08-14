---
description: Standard CMDB CRUD pattern with type-safe API wrappers and data transformation
enabled: true
tags:
  - cmdb
  - crud
  - api
  - typescript
  - service-layer
---

# CMDB CRUD Pattern

This skill describes the standard pattern for implementing CRUD operations on CMDB CI (Configuration Item) models, including service layer API wrappers, type definitions, and data transformation in the controller layer.

## Overview

CMDB CI data follows a wrapped structure where business data lives in a `properties` field. The service layer provides thin wrappers around generic CMDB APIs, and the controller layer handles data transformation between the wrapped `CmdbCI<T>` structure and flat DTOs.

## Generic CMDB API Layer

Located in `src/services/index.ts`, these are the base CMDB operations:

```typescript
import { request } from "cn-lib";
import type {
  ApiResponse,
  ApiRowsResponse,
  CmdbCI,
  CmdbQueryParams,
} from "./type";

/** 获取 CMDB CI 列表 */
export const apiGetCmdbCiList = <T>(
  modelName: string,
  params: CmdbQueryParams<T>,
): Promise<ApiRowsResponse<CmdbCI<T>>> => {
  return request.post(`/common-cmdb/model/${modelName}/ci/query`, params);
};

/** 获取 CMDB CI 详情 */
export const apiGetCmdbCiById = <T>(
  modelName: string,
  ciId: string,
): Promise<ApiResponse<CmdbCI<T>>> => {
  return request.get(`/common-cmdb/model/${modelName}/ci/${ciId}`);
};

/** 创建 CMDB CI */
export const apiCreateCmdbCi = <T>(
  modelName: string,
  params: CreateCmdbCiReq<T>,
): Promise<ApiResponse<string>> => {
  return request.post(`/common-cmdb/model/${modelName}/ci`, params);
};

/** 更新 CMDB CI */
export const apiUpdateCmdbCi = <T>(
  modelName: string,
  params: UpdateCmdbCiReq<T>,
): Promise<ApiResponse<string>> => {
  return request.put(`/common-cmdb/model/${modelName}/ci/${params.id}`, params);
};

/** 批量删除 CMDB CI */
export const apiBatchDeleteCmdbCi = (
  ids: string[],
): Promise<ApiResponse<string>> => {
  return request.delete("/common-cmdb/v2/model/ci/batch", ids);
};
```

## Type Definitions

### Core Types (from `src/services/type.ts`)

```typescript
/** CMDB CI 通用结构（properties 随 model 动态变化） */
export interface CmdbCI<T = Record<string, unknown>> {
  id: string;
  collection: string;
  properties: T;
  relatedCI: null;
  tags: [];
  tagFullUpdate: null;
  resourceGroups: null;
  bussinessGroups: null;
  mode: string;
  edgeFullUpdate: null;
  orUpdate: null;
  skipVerifyRequired: null;
  skipVerifyEditable: null;
  externalCi: null;
  totalCount: number;
  deleted: boolean;
  arangoId: string;
}

/** 创建 CMDB CI 请求 */
export interface CreateCmdbCiReq<T> {
  relatedCI: any;
  resourceGroups: any[];
  properties: T;
}

/** 更新 CMDB CI 请求 */
export interface UpdateCmdbCiReq<T> {
  id: string;
  relatedCI: any;
  resourceGroups: any[];
  properties: T;
}

/** CMDB 查询参数 */
export type CmdbQueryParams<T> = {
  bussinessGroupId: string | number | null;
  pageNum: number;
  pageSize: number;
  order?: "ASC" | "DESC";
  sort?: keyof T;
  query?: string;
  filters?: Partial<T>;
  exactFilters?: Partial<T>;
  queryGroup?: QueryGroup<T>;
};

/** API 列表响应 */
export interface ApiRowsResponse<T> {
  code: number;
  error: string | null;
  res: {
    pageNum: number;
    pageSize: number;
    total: number;
    list: T[];
  };
  trace: string | null;
}

/** API 通用响应 */
export interface ApiResponse<T> {
  code: number;
  error: string | null;
  res: T;
  trace: string | null;
}
```

## Module Implementation Pattern

For each CMDB model, create a module following the MVC + BFF structure:

### 1. Types (`types.ts`)

```typescript
import type {
  ApiRowsResponse,
  CmdbQueryParams,
  CmdbCI,
  CreateCmdbCiReq,
  UpdateCmdbCiReq,
} from "@/services/type";

/** Business DTO - flat structure for view layer */
export interface DataLineDTO {
  id: string;
  lineSubType?: string;
  operator?: string;
  bandwidth?: string;
  localLine?: string;
  provincialLine?: string;
  createTime?: string;
}

/** List request */
export type ApiGetDataLineReq = CmdbQueryParams<DataLineDTO>;

/** List response - wrapped in CmdbCI */
export type ApiGetDataLineRes = ApiRowsResponse<CmdbCI<DataLineDTO>>;

/** Create request */
export type ApiCreateDataLineReq = CreateCmdbCiReq<Omit<DataLineDTO, "id">>;

/** Update request */
export type ApiUpdateDataLineReq = UpdateCmdbCiReq<DataLineDTO>;
```

### 2. Service (`service.ts`)

Thin wrappers that provide the model name:

```typescript
import type { ApiResponse } from "@/services/type";
import {
  apiGetCmdbCiList,
  apiCreateCmdbCi,
  apiUpdateCmdbCi,
  apiBatchDeleteCmdbCi,
} from "@/services";
import type {
  ApiGetDataLineReq,
  ApiGetDataLineRes,
  ApiCreateDataLineReq,
  ApiUpdateDataLineReq,
} from "./types";

/** 获取数据专线列表 */
export const apiGetDataLineList = (
  params: ApiGetDataLineReq,
): Promise<ApiGetDataLineRes> => {
  return apiGetCmdbCiList<DataLineDTO>("dataLine", params);
};

/** 创建数据专线 */
export const apiCreateDataLine = (
  params: ApiCreateDataLineReq,
): Promise<ApiResponse<CmdbCI<DataLineDTO>>> => {
  return apiCreateCmdbCi("dataLine", params);
};

/** 更新数据专线 */
export const apiUpdateDataLine = (
  params: ApiUpdateDataLineReq,
): Promise<ApiResponse<CmdbCI<DataLineDTO>>> => {
  return apiUpdateCmdbCi("dataLine", params);
};

/** 删除数据专线（批量） */
export const apiDeleteDataLine = (
  ids: string[],
): Promise<ApiResponse<null>> => {
  return apiBatchDeleteCmdbCi(ids);
};
```

### 3. Controller (`controller.ts`)

Transform between wrapped `CmdbCI<T>` structure and flat DTOs:

```typescript
import type { ApiGetDataLineReq } from "./types";
import { apiGetDataLineList } from "./service";

/** 获取数据专线列表 */
export const getDataLineList = async (params: ApiGetDataLineReq) => {
  const response = await apiGetDataLineList(params);

  return {
    list:
      response.res?.list?.map((item) => ({
        ...item.properties,
        id: item.id,
      })) ?? [],
    total: response.res?.total ?? 0,
  };
};
```

**Key transformation**: `CmdbCI<T>` → flat DTO by spreading `item.properties` and adding `item.id`.

### 4. Edit Drawer (`components/edit.tsx`)

Transform form data to `CreateCmdbCiReq` / `UpdateCmdbCiReq`:

```typescript
import type { DataLineDTO } from "../types";
import { apiCreateDataLine, apiUpdateDataLine } from "../service";

const handleSubmit = async () => {
  const values = await form.validateFields();

  if (isEdit) {
    // Update: wrap in UpdateCmdbCiReq
    await apiUpdateDataLine({
      id: record.current!.id,
      relatedCI: {},
      resourceGroups: [],
      properties: values,
    });
  } else {
    // Create: wrap in CreateCmdbCiReq
    await apiCreateDataLine({
      relatedCI: {},
      resourceGroups: [],
      properties: values,
    });
  }

  message.success(isEdit ? "编辑成功" : "新增成功");
  handleClose();
};
```

**Key transformation**: Form values → `properties` field in the request body.

### 5. Delete Operation (in tab component)

```typescript
import { apiDeleteDataLine } from "../service";

// Single delete - wrap in array
const handleDelete = async (id: string) => {
  Modal.confirm({
    title: "确认删除",
    content: "确定要删除这条记录吗？",
    onOk: async () => {
      await apiDeleteDataLine([id]);
      message.success("删除成功");
      await run();
    },
  });
};

// Batch delete - pass array directly
const handleBatchDelete = async () => {
  Modal.confirm({
    title: "确认删除",
    content: `确定要删除选中的 ${selectedRowKeys.length} 条记录吗？`,
    onOk: async () => {
      await apiDeleteDataLine(selectedRowKeys);
      message.success("删除成功");
      setSelectedRowKeys([]);
      await run();
    },
  });
};
```

## Data Flow

### List (Read)

```
API Response: ApiRowsResponse<CmdbCI<T>>
  ↓
  list: [
    {
      id: "1",
      collection: "dataLine",
      properties: { lineSubType: "MSTP", operator: "中国电信", ... },
      ...
    }
  ]
  ↓ Controller
  list: [
    { id: "1", lineSubType: "MSTP", operator: "中国电信", ... }
  ]
  ↓ View
  <Table dataSource={list} />
```

### Create / Update (Write)

```
Form Values: { lineSubType: "MSTP", operator: "中国电信", ... }
  ↓ Edit Drawer
  {
    relatedCI: {},
    resourceGroups: [],
    properties: { lineSubType: "MSTP", operator: "中国电信", ... }
  }
  ↓ Service
  POST/PUT /sjzy-automation-service/dataLine
  ↓ API Response
  CmdbCI<T>
```

## Naming Conventions

- **Model name**: camelCase, matches CMDB collection name (e.g., `dataLine`, `internetLine`, `targetIPAddress`)
- **DTO interface**: `{ModelName}DTO` (e.g., `DataLineDTO`, `InternetLineDTO`)
- **List request type**: `ApiGet{ModelName}Req = CmdbQueryParams<{ModelName}DTO>`
- **List response type**: `ApiGet{ModelName}Res = ApiRowsResponse<CmdbCI<{ModelName}DTO>>`
- **Create request type**: `ApiCreate{ModelName}Req = CreateCmdbCiReq<Omit<{ModelName}DTO, "id">>`
- **Update request type**: `ApiUpdate{ModelName}Req = UpdateCmdbCiReq<{ModelName}DTO>`
- **API functions**: `apiGet{ModelName}List`, `apiCreate{ModelName}`, `apiUpdate{ModelName}`, `apiDelete{ModelName}`

## Complete Example

See `src/pages/link-cost/` for a complete working example of this pattern:

- `types.ts` - Type definitions for DataLineDTO and InternetLineDTO
- `service.ts` - Thin API wrappers
- `controller.ts` - Data transformation logic
- `components/data-line-edit.tsx` - Edit drawer with proper request wrapping

## When to Use This Pattern

Use this pattern when:

- Working with CMDB CI models in the SJZY system
- The backend API follows the `CmdbCI<T>` wrapped structure
- You need standard CRUD operations (list, create, update, delete)
- The model is stored in ArangoDB via the CMDB service

For non-CMDB APIs or custom endpoints, use the regular `request` utility directly.
