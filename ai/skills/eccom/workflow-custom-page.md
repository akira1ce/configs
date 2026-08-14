# workflow-custom-page

Create a custom page component for workflow process integration.

## Usage

```
/workflow-custom-page <page-name> [--path <module-path>]
```

## What it does

Generates a complete workflow custom page following the project's BFF + MVC architecture pattern. The page is embedded into workflow configuration on the platform and uses a **register-based callback pattern** for save/validate operations.

## Core Implementation Pattern

### Props Interface (CustomPanelProps)

```typescript
interface CustomPanelProps {
  // 工单数据
  workOrder: any;
  
  // 是否在查看模式下显示
  showInViewMode: boolean;
  
  // 注册校验函数（提交时调用）
  registerValidate?: (fn: (ctx: { approveType: string }) => { 
    finish: boolean; 
    values: any 
  }) => void;
  
  // 注册暂存函数（暂存时调用）
  registerSave?: (fn: () => { 
    values: any; 
    initialValues: any 
  }) => void;
  
  // 注册回调函数（提交后执行额外操作）
  registerCallback?: (fn: (ctx: { 
    approveType: string; 
    ticketId: string 
  }) => void) => void;
  
  // 初始值（用于回显）
  initialValues?: any;
  
  // 组件唯一标识
  componentKey?: string;
  
  // 是否可编辑
  editable?: boolean;
}
```

### useEffect Registration Logic

The core logic is registering save/validate callbacks in useEffect:

```typescript
useEffect(() => {
  // 非编辑模式不注册回调
  if (!isEditable) return;

  // 注册暂存函数 - 返回当前数据
  registerSave?.(() => ({
    values: { after_hearing_data: dataRef.current },
    initialValues,
  }));

  // 注册校验函数 - 返回校验结果和数据
  registerValidate?.(({ approveType }: { approveType: string }) => ({
    finish: true,  // 校验是否通过
    values: { after_hearing_data: dataRef.current },
  }));
  
  // 可选：注册提交后回调
  registerCallback?.(({ approveType, ticketId }) => {
    // 提交成功后的额外操作
    console.log('Submitted', approveType, ticketId);
  });
}, [isEditable]);
```

### Data Flow

1. **Initialization**
   - Extract initial data from `initialValues` or `workOrder.otherVars`
   - Initialize form state and refs

2. **Draft Save (暂存)**
   - Platform calls the function registered via `registerSave`
   - Function returns current form values + initialValues
   - No validation required

3. **Validation & Submit (提交)**
   - Platform calls the function registered via `registerValidate`
   - Function validates data and returns `{ finish: boolean, values: any }`
   - If `finish: true`, submission proceeds with `values`

4. **Post-Submit Callback**
   - Platform calls the function registered via `registerCallback` after successful submit
   - Receives `approveType` and `ticketId` for additional operations

### Key Patterns

- **Use `useRef` for data** - Store form data in `dataRef.current` so registered callbacks always access latest state
- **Check `isEditable`** - Only register callbacks when page is in edit mode
- **Return `initialValues`** - registerSave must return both current values and initialValues for comparison
- **Validate in registerValidate** - Throw errors or return `finish: false` if validation fails

## File Structure

Creates:
```
src/pages/<module>/
  ├── service.ts       # API requests (if needed)
  ├── controller.ts    # Data transformation (if needed)
  ├── page.tsx         # Main workflow custom panel
  └── types.ts         # CustomPanelProps and data types
```

## Example

```bash
/workflow-custom-page hearing-review --path hearing
```

Generates a workflow custom panel at `src/pages/hearing/page.tsx` with:
- CustomPanelProps interface
- useEffect with registerSave/registerValidate
- dataRef for tracking form state
- Initial data extraction from workOrder.otherVars
- Editable/readonly mode support
