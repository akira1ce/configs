---
description: Standard Zustand store pattern with state/actions separation and selector optimization
enabled: true
tags:
  - zustand
  - state-management
  - react
  - typescript
---

# Zustand Store Pattern

This skill describes the standard Zustand store pattern used in this project, with state/actions separation and selector optimization.

## Pattern Overview

We use a Zustand store pattern that separates state and actions, leveraging `createSelectors` for optimized component subscriptions.

## Store Structure

```typescript
import { create } from "zustand";
import { createSelectors } from "@/utils/zustand";

// 1. Define state interface (read-only data)
interface ExampleState {
  /** Count value */
  count: number;
  /** User name */
  userName: string;
}

// 2. Create store with initial state only
export const useExample = createSelectors(
  create<ExampleState>(() => ({
    count: 0,
    userName: "",
  })),
);

// 3. Extract setState for actions
const set = useExample.setState;

// 4. Export actions separately
export const exampleActions = {
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
  setUserName: (name: string) => set({ userName: name }),
  reset: () => set({ count: 0, userName: "" }),
};
```

## Usage in Components

### Reading State

Use `useExample.use.xxx()` to subscribe to specific state slices. This ensures the component only re-renders when that specific state changes.

```typescript
import { useExample } from "./store";

export const DisplayComponent = () => {
	// Only re-renders when count changes
	const count = useExample.use.count();

	// Only re-renders when userName changes
	const userName = useExample.use.userName();

	return (
		<div>
			<p>Count: {count}</p>
			<p>User: {userName}</p>
		</div>
	);
};
```

### Calling Actions

Import and call actions directly. Actions don't cause component re-renders because they're not hooks.

```typescript
import { exampleActions } from "./store";

export const ControlComponent = () => {
	const handleIncrement = () => {
		exampleActions.increment();
	};

	const handleSetName = () => {
		exampleActions.setUserName("Alice");
	};

	return (
		<div>
			<button onClick={handleIncrement}>Increment</button>
			<button onClick={handleSetName}>Set Name</button>
		</div>
	);
};
```

### In useEffect

Actions can be called directly in `useEffect` without adding them to the dependency array.

```typescript
import { exampleActions } from "./store";

export const DataFetcher = () => {
	const { data, total } = useFetchData();

	useEffect(() => {
		// No need to add exampleActions.setCount to dependencies
		exampleActions.setCount(total);
	}, [total]);

	return <div>...</div>;
};
```

## Benefits

1. **State/Actions Separation**: Clear distinction between read and write operations
2. **Optimized Re-renders**: Components only re-render when their subscribed state changes
3. **No Dependency Issues**: Actions are stable references, no need to add to `useEffect` deps
4. **Better Performance**: Calling actions doesn't trigger re-renders in the calling component
5. **Type Safety**: Full TypeScript support for state and actions

## Real-World Example

Here's a complete example from the `link-cost` module:

```typescript
// store.ts
import { create } from "zustand";
import { createSelectors } from "@/utils/zustand";

interface LinkCostState {
  dataLineTotal: number;
  internetLineTotal: number;
}

export const useLinkCost = createSelectors(
  create<LinkCostState>(() => ({
    dataLineTotal: 0,
    internetLineTotal: 0,
  })),
);

const set = useLinkCost.setState;

export const linkCostActions = {
  setDataLineTotal: (total: number) => set({ dataLineTotal: total }),
  setInternetLineTotal: (total: number) => set({ internetLineTotal: total }),
};
```

```typescript
// page.tsx - Reading state
import { useLinkCost } from "./store";

export const Page = () => {
	const dataLineTotal = useLinkCost.use.dataLineTotal();
	const internetLineTotal = useLinkCost.use.internetLineTotal();

	return (
		<Tabs items={[
			{ label: `Data Line (${dataLineTotal})`, ... },
			{ label: `Internet Line (${internetLineTotal})`, ... },
		]} />
	);
};
```

```typescript
// data-line-tab.tsx - Writing state
import { linkCostActions } from "../store";

export const DataLineTab = () => {
	const { total } = useTable(getDataLineList);

	useEffect(() => {
		linkCostActions.setDataLineTotal(total);
	}, [total]);

	return <Table ... />;
};
```

## Naming Conventions

- Store hook: `use{ModuleName}` (e.g., `useLinkCost`, `useCounter`)
- Actions object: `{moduleName}Actions` (e.g., `linkCostActions`, `counterActions`)
- State interface: `{ModuleName}State` (e.g., `LinkCostState`, `CounterState`)

## When to Use This Pattern

Use this pattern when:

- Multiple components need to share state
- You want to display aggregated data in parent components (like totals in tab titles)
- You need to update state from components that don't directly consume it
- Performance optimization is important (avoid unnecessary re-renders)

For local component state or state that doesn't need to be shared, use React's `useState` instead.
