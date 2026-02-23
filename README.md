# NumberFlow

Rails helper + Stimulus controller for smooth integer digit transitions inspired by [number-flow](https://github.com/barvian/number-flow).

[![Gem Version](https://badge.fury.io/rb/number_flow.svg)](https://badge.fury.io/rb/number_flow)

`number_flow` ships both CSS and JavaScript assets inside the gem, so you do not need a separate npm package.

## Original Project

This gem is inspired by and references the original Number Flow project by Barvian:
- https://github.com/barvian/number-flow

`number_flow` is a Ruby/Rails adaptation and is not an official package from the original project maintainers.

## Installation

```sh
bundle add number_flow
```

Or:

```sh
gem install number_flow
```

## Rails Setup

### 1) Ensure the gem stylesheet is loaded

Add this in your layout (or import into your main stylesheet):

```erb
<%= stylesheet_link_tag "number_flow", "data-turbo-track": "reload" %>
```

### 2) Register the Stimulus controller

With importmap (`config/importmap.rb`):

```ruby
pin "number_flow/controller", to: "number_flow/controller.js"
```

Then register in `app/javascript/controllers/index.js`:

```js
import { application } from "./application"
import NumberFlowController from "number_flow/controller"

application.register("number-flow", NumberFlowController)
```

## Usage

Render a value:

```erb
<%= number_flow_tag(12_345) %>
```

Render with options:

```erb
<%= number_flow_tag(
  12_345,
  class: "kpi-value",
  duration: 550,
  easing: "ease-out",
  stagger: 30,
  grouping: true,
  aria_label: "Current total users"
) %>
```

Update from JavaScript:

```js
const element = document.querySelector("[data-controller='number-flow']")
element.dispatchEvent(
  new CustomEvent("number-flow:update", {
    detail: { value: 12987 }
  })
)
```

## API

### `number_flow_tag(value, **options)`

Options:
- `id:` DOM id
- `class:` extra CSS classes
- `duration:` animation duration in milliseconds (default: `400`)
- `easing:` CSS easing function (default: `cubic-bezier(0.2, 0, 0, 1)`)
- `stagger:` per-digit delay in milliseconds (default: `20`)
- `grouping:` show thousands separators (default: `false`)
- `aria_label:` explicit `aria-label`
- `data:` additional data attributes merged into the root element

## Accessibility

- Root element uses `role="status"` and `aria-live="polite"`.
- `prefers-reduced-motion: reduce` disables animated transitions while still updating values.

## Error Handling

`number_flow_tag` raises `ArgumentError` when `value` cannot be coerced into an integer.

## Development

```sh
bundle exec rake test
bundle exec rubocop
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/dpaluy/number_flow/issues).

## License

MIT. See `LICENSE.txt`.
