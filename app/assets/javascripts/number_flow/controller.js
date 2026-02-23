import { Controller } from "@hotwired/stimulus"

const UPDATE_EVENT = "number-flow:update"

export default class extends Controller {
  static values = {
    value: Number,
    duration: Number,
    easing: String,
    stagger: Number,
    grouping: Boolean
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

    this.updateTo(Math.trunc(nextValue))
  }

  updateTo(nextValue) {
    const normalized = Math.trunc(nextValue)
    if (normalized === this.currentValue) return

    this.applyTimingVariables()
    this.render(normalized, !this.prefersReducedMotion())
    this.currentValue = normalized
    this.valueValue = normalized
  }

  render(value, animate) {
    const previousDigits = this.currentParts.filter((part) => part.kind === "digit").map((part) => part.value)
    const nextParts = this.partsFor(value)
    const nextDigits = nextParts.filter((part) => part.kind === "digit").map((part) => part.value)

    let digitIndex = 0
    const totalDigits = nextDigits.length
    const fragment = document.createDocumentFragment()

    nextParts.forEach((part) => {
      if (part.kind === "separator") {
        fragment.appendChild(this.buildSeparatorNode(part.value))
        return
      }

      const remaining = totalDigits - digitIndex
      const previousIndex = previousDigits.length - remaining
      const fromDigit = previousIndex >= 0 ? previousDigits[previousIndex] : 0
      const toDigit = part.value
      const indexFromRight = totalDigits - digitIndex - 1
      fragment.appendChild(this.buildDigitNode(fromDigit, toDigit, indexFromRight, animate))
      digitIndex += 1
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

  partsFor(value) {
    return this.formattedString(value).split("").map((char) => {
      if (/\d/.test(char)) {
        return { kind: "digit", value: Number(char) }
      }

      return { kind: "separator", value: char }
    })
  }

  formattedString(value) {
    const sign = value < 0 ? "-" : ""
    const digits = Math.abs(value).toString()
    const groupedDigits = this.groupingValue ? digits.replace(/\B(?=(\d{3})+(?!\d))/g, ",") : digits
    return `${sign}${groupedDigits}`
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
      return Math.trunc(this.valueValue)
    }

    const inlineValue = Number(this.element.getAttribute("data-number-flow-value-value"))
    if (Number.isFinite(inlineValue)) {
      return Math.trunc(inlineValue)
    }

    return 0
  }

  prefersReducedMotion() {
    return this.reducedMotionMedia.matches
  }

  durationOrDefault() {
    return this.hasDurationValue ? this.durationValue : 400
  }

  easingOrDefault() {
    return this.hasEasingValue ? this.easingValue : "cubic-bezier(0.2, 0, 0, 1)"
  }

  staggerOrDefault() {
    return this.hasStaggerValue ? this.staggerValue : 20
  }

  isDevelopmentEnv() {
    return typeof document !== "undefined" && document.location?.hostname === "localhost"
  }
}

