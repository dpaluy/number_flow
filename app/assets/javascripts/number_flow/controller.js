import { Controller } from "@hotwired/stimulus"

const UPDATE_EVENT = "number-flow:update"

export default class extends Controller {
  static values = {
    value: Number,
    duration: Number,
    easing: String,
    stagger: Number,
    grouping: Boolean,
    precision: Number,
    locale: String
  }

  connect() {
    this.handleUpdate = this.handleUpdate.bind(this)
    this.reducedMotionMedia = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.element.addEventListener(UPDATE_EVENT, this.handleUpdate)

    this.applyTimingVariables()
    this.currentValue = this.initialValue()
    this.currentParts = []
    this.render(this.currentValue, false)
  }

  disconnect() {
    this.element.removeEventListener(UPDATE_EVENT, this.handleUpdate)
  }

  valueValueChanged(nextValue, previousValue) {
    if (previousValue === undefined) return

    this.updateTo(nextValue)
  }

  handleUpdate(event) {
    const nextValue = Number(event?.detail?.value)
    if (!Number.isFinite(nextValue)) {
      if (this.isDevelopmentEnv()) {
        console.warn("[number_flow] Ignoring non-numeric number-flow:update payload.")
      }
      return
    }

    this.updateTo(nextValue)
  }

  updateTo(nextValue) {
    if (nextValue === this.currentValue) return
    if (!this.currentParts) return // Guard: not yet connected

    this.applyTimingVariables()
    this.render(nextValue, !this.prefersReducedMotion())
    this.currentValue = nextValue
    this.valueValue = nextValue
  }

  render(value, animate) {
    const previousParts = this.currentParts
    const nextParts = this.partsFor(value)
    const fragment = document.createDocumentFragment()

    nextParts.forEach((part, index) => {
      if (part.kind === "separator") {
        fragment.appendChild(this.buildSeparatorNode(part.value))
        return
      }

      const { fromDigit } = this.alignDigit(previousParts, nextParts, index)
      const indexFromRight = nextParts.length - index - 1
      fragment.appendChild(this.buildDigitNode(fromDigit, part.value, indexFromRight, animate))
    })

    this.element.replaceChildren(fragment)
    this.element.setAttribute("aria-label", this.formattedString(value))

    if (animate && !this.prefersReducedMotion()) {
      requestAnimationFrame(() => {
        this.element.querySelectorAll(".nf__track--animated").forEach((track) => {
          track.style.setProperty("--nf-current-digit", track.dataset.toDigit)
        })
      })
    }

    this.currentParts = nextParts
  }

  alignDigit(previousParts, nextParts, currentIndex) {
    const nextDigits = nextParts.filter((p) => p.kind === "digit")
    const previousDigits = previousParts.filter((p) => p.kind === "digit")

    const currentDigitIndex = nextParts.slice(0, currentIndex).filter((p) => p.kind === "digit").length
    const remaining = nextDigits.length - currentDigitIndex
    const previousIndex = previousDigits.length - remaining

    const fromDigit = previousIndex >= 0 ? previousDigits[previousIndex].value : 0
    const toDigit = nextParts[currentIndex].value

    return { fromDigit, toDigit }
  }

  partsFor(value) {
    return this.formattedString(value).split("").map((char) => {
      if (/\d/.test(char)) {
        return { kind: "digit", value: Number(char) }
      }

      return { kind: "separator", value: char }
    })
  }

  formattedString(value) {
    const formatter = new Intl.NumberFormat(this.localeValue || undefined, {
      useGrouping: this.groupingValue,
      minimumFractionDigits: this.precisionValue,
      maximumFractionDigits: this.precisionValue
    })

    const formatted = formatter.format(Math.abs(value))
    return value < 0 ? `-${formatted}` : formatted
  }

  buildDigitNode(fromDigit, toDigit, indexFromRight, animate) {
    const digit = document.createElement("span")
    digit.className = "nf__digit"
    digit.dataset.digit = String(toDigit)
    digit.style.setProperty("--nf-index-from-right", String(indexFromRight))

    const track = document.createElement("span")
    track.className = animate ? "nf__track nf__track--animated" : "nf__track"
    track.dataset.toDigit = String(toDigit)
    track.style.setProperty("--nf-from-digit", String(fromDigit))
    track.style.setProperty("--nf-to-digit", String(toDigit))
    track.style.setProperty("--nf-current-digit", String(animate ? fromDigit : toDigit))

    for (let value = 0; value <= 9; value += 1) {
      const cell = document.createElement("span")
      cell.className = "nf__cell"
      cell.setAttribute("aria-hidden", "true")
      cell.textContent = String(value)
      track.appendChild(cell)
    }

    digit.appendChild(track)
    return digit
  }

  buildSeparatorNode(value) {
    const separator = document.createElement("span")
    separator.className = "nf__separator"
    separator.setAttribute("aria-hidden", "true")
    separator.textContent = value
    return separator
  }

  applyTimingVariables() {
    this.element.style.setProperty("--nf-duration", `${this.durationOrDefault()}ms`)
    this.element.style.setProperty("--nf-easing", this.easingOrDefault())
    this.element.style.setProperty("--nf-stagger", `${this.staggerOrDefault()}ms`)
  }

  initialValue() {
    if (this.hasValueValue && Number.isFinite(this.valueValue)) {
      return this.valueValue
    }

    const inlineValue = Number(this.element.getAttribute("data-number-flow-value-value"))
    if (Number.isFinite(inlineValue)) {
      return inlineValue
    }

    return 0
  }

  prefersReducedMotion() {
    return this.reducedMotionMedia?.matches === true
  }

  durationOrDefault() {
    return this.hasDurationValue ? this.durationValue : 400
  }

  easingOrDefault() {
    return this.hasEasingValue ? this.easingValue : "cubic-bezier(0.2, 0, 1)"
  }

  staggerOrDefault() {
    return this.hasStaggerValue ? this.staggerValue : 20
  }

  isDevelopmentEnv() {
    return typeof document !== "undefined" && document.location?.hostname === "localhost"
  }
}
