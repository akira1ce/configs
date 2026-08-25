---
name: uncontrolled-drawer
description: Uncontrolled drawer pattern with imperative ref control and parent data passing
tags: [react, antd, drawer, ref, pattern]
---

# Uncontrolled Drawer Pattern

Control drawer opening and closing imperatively via ref, and pass data from parent component through parameters.

## Use Cases

- Need to open drawer imperatively from parent component
- Drawer state doesn't need to be managed by parent
- Need to pass dynamic data to drawer when opening

## Code Template

```tsx
import { useMemoizedFn } from "ahooks";
import { forwardRef, useImperativeHandle, useRef, useState } from "react";
import { Drawer } from "antd";
import Button from "antd/es/button";

export interface DrawerProps {
  onClose?: () => void;
}

export interface DrawerRef {
  handleOpen: (record: any) => void;
}

// Uncontrolled drawer
export const UncontrolledDrawer = forwardRef<DrawerRef, DrawerProps>((props, ref) => {
  const { onClose } = props;

  const [open, setOpen] = useState(false);
  const record = useRef<any>(undefined);

  // Open drawer
  const handleOpen: DrawerRef["handleOpen"] = useMemoizedFn((recordVal) => {
    setOpen(true);
    record.current = recordVal;
  });

  // Close drawer
  const handleClose = () => {
    setOpen(false);
    record.current = undefined;
    onClose?.();
  };

  const handleOk = async () => {
    try {
      // Handle confirmation logic
      handleClose();
    } catch (error) {
      // Error handling
    }
  };

  useImperativeHandle(ref, () => ({ handleOpen }));

  return (
    <Drawer
      title="Title"
      open={open}
      onClose={handleClose}
      width={800}
      footer={
        <div className="flex justify-end">
          <Button type="default" onClick={handleClose}>
            Cancel
          </Button>
          <Button type="primary" onClick={handleOk}>
            Confirm
          </Button>
        </div>
      }
    >
      {/* Drawer content */}
    </Drawer>
  );
});
```

## Usage

```tsx
import { useRef } from "react";
import { UncontrolledDrawer, DrawerRef } from "./UncontrolledDrawer";

export const ParentComponent = () => {
  const drawerRef = useRef<DrawerRef>(null);

  const handleOpenDrawer = (record: any) => {
    drawerRef.current?.handleOpen(record);
  };

  return (
    <div>
      <button onClick={() => handleOpenDrawer({ id: 1, name: "Example" })}>
        Open Drawer
      </button>
      <UncontrolledDrawer ref={drawerRef} />
    </div>
  );
};
```

## Key Points

1. **State Management**: Drawer manages its own `open` state, parent doesn't need to maintain it
2. **Data Passing**: Store parent-passed data via `record.current`
3. **Imperative API**: Use `useImperativeHandle` to expose `handleOpen` method
4. **Cleanup**: Clear `record.current` on close to prevent memory leaks
5. **Callback Notification**: Notify parent via `onClose` callback
6. **Performance**: Use `useMemoizedFn` to avoid recreating `handleOpen`

## Variants

### Drawer with Form

```tsx
const [form] = Form.useForm();

const handleOpen: DrawerRef["handleOpen"] = useMemoizedFn((recordVal) => {
  setOpen(true);
  record.current = recordVal;
  form.setFieldsValue(recordVal); // Set form initial values
});

const handleClose = () => {
  setOpen(false);
  record.current = undefined;
  form.resetFields(); // Clear form
  onClose?.();
};

const handleOk = async () => {
  try {
    const values = await form.validateFields();
    // Process form data
    handleClose();
  } catch (error) {
    // Validation failed
  }
};
```

### Edit/Create Mode

```tsx
const isEdit = !!record.current?.id;

const handleOk = async () => {
  try {
    const values = await form.validateFields();
    
    if (isEdit) {
      await apiUpdate(record.current.id, values);
    } else {
      await apiCreate(values);
    }
    
    handleClose();
  } catch (error) {}
};
```
