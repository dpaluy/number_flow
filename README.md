# NumberFlow

Rails helper + Stimulus controller for smooth number digit transitions (integers, decimals, locale-aware) inspired by [number-flow](https://github.com/barvian/number-flow).

[![CI](https://github.com/dpaluy/number_flow/actions/workflows/ci.yml/badge.svg)](https://github.com/dpaluy/number_flow/actions/workflows/ci.yml)
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

#### Sprockets / Importmap

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

#### Vite Rails

Use the built-in generator to copy assets into `app/frontend/`:

```sh
rails g number_flow:install --vite
```

This copies:
- `controller.js` → `app/frontend/controllers/number_flow_controller.js`
- `number_flow.css` → `app/frontend/stylesheets/number_flow.css`

If `app/frontend/entrypoints/application.js` exists, the controller import and registration are appended automatically (idempotent — re-running won't duplicate).

Without `--vite`, the generator prints the Sprockets/importmap setup instructions above.

## Usage

Render an integer:

```erb
<%= number_flow_tag(12_345) %>
```

Render a decimal with precision:

```erb
<%= number_flow_tag(12.34, precision: 2) %>
```

Locale-aware formatting (uses `Intl.NumberFormat` on the client):

```erb
<%= number_flow_tag(1234.5, precision: 1, locale: "de-DE", grouping: true) %>
<!-- renders as 1.234,5 -->
```

Render with options:

```erb
<%= number_flow_tag(
  12_345.67,
  precision: 2,
  class: "kpi-value",
  duration: 550,
  easing: "ease-out",
  stagger: 30,
  grouping: true,
  locale: "en-US",
  aria_label: "Current total revenue"
) %>
```

Update from JavaScript:

```js
const element = document.querySelector("[data-controller='number-flow']")
element.dispatchEvent(
  new CustomEvent("number-flow:update", {
    detail: { value: 12987.50 }
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
- `precision:` number of decimal digits (default: `0` — integer mode)
- `locale:` BCP 47 locale tag for formatting (default: `nil` → browser default)
- `aria_label:` explicit `aria-label`
- `data:` additional data attributes merged into the root element

## Optional ViewComponent Wrapper

If your app uses [ViewComponent](https://github.com/github/view_component), `NumberFlow::Component` is available as a thin wrapper:

```erb
<%= render(NumberFlow::Component.new(value: 42, precision: 2)) %>
```

The component is only defined when the `view_component` gem is present. The gem does **not** add `view_component` as a runtime dependency. Add it to your app's Gemfile to use the component API.

## Accessibility

- Root element uses `role="status"` and `aria-live="polite"`.
- `prefers-reduced-motion: reduce` disables animated transitions while still updating values.

## Error Handling

`number_flow_tag` raises `ArgumentError` when `value` cannot be coerced into a numeric value.

## Why No npm Package?

**Decision: gem-only distribution.** The Stimulus controller consumes data attributes (`data-number-flow-value-value`, `data-number-flow-precision-value`, etc.) that are emitted by the Ruby helper. The JS is not standalone — it depends on the gem's markup contract. Publishing to npm would:

1. **Double maintenance** for no standalone value — two version tracks, two release workflows, two changelogs.
2. **Not solve a real problem** — Vite/importmap integration (via the install generator) already covers asset resolution without npm.
3. **Conflict with positioning** — the gem already markets gem-only as a feature.

**Revisit trigger:** if a framework-agnostic core (pure formatting + DOM, no Rails-helper coupling) is extracted, or if community demand materializes for importing the controller from `@dpaluy/number_flow` in a non-Rails context. Until then: won't ship.

## Development

```sh
bundle exec rake test
bundle exec rubocop
```

Browser system tests require Chrome/Chromium:

```sh
RUN_SYSTEM_TESTS=true bundle exec rake test
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/dpaluy/number_flow/issues).

## License

MIT. See `LICENSE.txt`.
