---
name: mvc-bff
description: MVC architecture with BFF layer for frontend-backend separation
tags: [architecture, mvc, bff, nestjs, react, pattern]
---

# MVC + BFF Style

## Core Rule

- View owns page-related data shaping.
- Controller coordinates View and Service.
- Service owns business logic and API calls.

## Responsibilities

### View

- Form parameters
- Pagination state
- Default values
- Date split and merge
- Other page-specific request construction

### Controller

- Call orchestration
- Light error handling
- Light response adaptation
- Small API shape bridging when needed

### Service

- Business logic
- Data aggregation
- API requests
- Request and response types

## Parameter Rules

- Function parameters should use a single `params` object.
- Request types should use `ApiXxxxReq` naming.
- If `id` is needed, put it inside the request type.
- Avoid positional parameters like `(id, data)`.

## Boundary Rules

- Page-related changes belong in View.
- API-shape changes belong in Controller.
- Business-related changes belong in Service.
- Keep View readable and local to the page.
- Keep Controller thin.
- Keep Service independent of page structure.

## Example

```ts
// View
const params = {
  properties: {
    name: values.name,
    ips: values.ips.join(","),
  },
  resourceGroups: [],
  relatedCI: {},
};

// Service
export const apiCreateIPAddressGroup = (params: ApiCreateIPAddressGroupReq) => {
  return request.post("/common-cmdb/model/targetIPAddress/ci", params);
};
```

## Practical Notes

- If the request data mostly comes from the page, build it in View.
- If the request data is derived from multiple service responses, let Controller assemble it.
- If the logic is about HTTP, query adapters, or response mapping, keep it in Service or Controller.
