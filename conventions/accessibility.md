# Accessibility

Baseline is WCAG 2.2 Level AA. Every rule below maps to a Level A or AA success
criterion — treat a violation the same as a failing test, not a style nit.

## Semantic structure

- Use native HTML elements for their native purpose (`button`, `a`, `nav`,
  `main`, `header`, `footer`, `table`, `ul`/`ol`) before reaching for ARIA —
  "no ARIA is better than bad ARIA." *(4.1.2)*
- One `<h1>` per page; heading levels don't skip (`h2` → `h4` without an `h3`
  is a bug). Headings describe the section that follows, not styling. *(1.3.1, 2.4.6)*
- Landmark regions (`header`, `nav`, `main`, `footer`, `aside`) appear once
  per page where singular, and are labeled with `aria-label` when there's more
  than one of the same type (two `nav`s need distinct labels). *(1.3.1, 2.4.1)*
- Reading/DOM order matches visual order. Don't use CSS (`order`, absolute
  positioning, grid placement) to visually reorder content in a way that
  diverges from source order — screen readers and keyboard nav follow the DOM. *(1.3.2, 2.4.3)*
- Lists (`ul`/`ol`/`dl`) markup actual lists; tables (`table`) markup actual
  tabular data with `<th scope="col|row">` — never a table for layout. *(1.3.1)*

## Keyboard

- Every interactive control is operable by keyboard alone: `Tab`/`Shift+Tab`
  to reach it, `Enter`/`Space` to activate, arrow keys for composite widgets
  (menus, tabs, listboxes) per the ARIA Authoring Practices pattern. *(2.1.1)*
- No keyboard trap — a user can always tab out of a widget (modal, custom
  dropdown) without a mouse. *(2.1.2)*
- Focus order follows a logical, predictable sequence (generally DOM order);
  don't hand-tune `tabindex` values above `0` to reorder focus — fix the DOM
  order instead. `tabindex="-1"` for programmatic-only focus targets is fine. *(2.4.3)*
- Visible focus indicator on every focusable element — never
  `outline: none`/`:focus { outline: 0 }` without a replacement indicator that
  meets the 3:1 non-text contrast minimum against its background. *(2.4.7, 1.4.11)*
- Opening a modal/dialog moves focus into it and traps it there; closing
  returns focus to the trigger element. *(2.4.3, 4.1.2)*
- Custom interactive elements (`<div onClick>`, custom dropdowns/comboboxes)
  get `role`, `tabindex="0"`, and the full keyboard interaction pattern the
  native element would give for free — or better, use the native element. *(4.1.2)*

## Forms

- Every input has a programmatically associated `<label>` (`for`/`id`, or
  wrapping) — a placeholder is never a substitute for a label. *(1.3.1, 3.3.2)*
- Required fields and format constraints are stated in text (not color/icon
  alone) before or at the point of input, not only revealed on error. *(3.3.2)*
- Validation errors are (a) associated with their field via
  `aria-describedby`, (b) announced to assistive tech (`aria-live` region or
  moving focus to a summary), and (c) describe what's wrong and how to fix it
  in text — not just a red border. *(3.3.1, 3.3.3, 1.4.1)*
- Grouped inputs (radio sets, checkbox sets, address fields) are wrapped in
  `<fieldset>`/`<legend>` describing the group. *(1.3.1)*
- Forms that time out warn the user and offer a way to extend, unless the
  time limit is essential (e.g. an auction). *(2.2.1)*

## Color & visual presentation

- Text contrast is at least 4.5:1 for normal text, 3:1 for large text (≥24px,
  or ≥19px bold) against its background. *(1.4.3)*
- Non-text elements that convey meaning (icons, focus indicators, form field
  borders, chart lines) meet 3:1 contrast against adjacent colors. *(1.4.11)*
- Color is never the only signal for meaning — pair a color change with text,
  an icon, or a pattern (error states, chart series, required-field markers,
  links within body text need underline or equivalent non-color distinction). *(1.4.1)*
- Content and controls remain usable at 200% browser zoom and at 400% zoom
  reflowed to a single column (320px CSS width) without horizontal scrolling
  or loss of functionality. *(1.4.4, 1.4.10)*
- Don't disable pinch-zoom or set
  `maximum-scale=1`/`user-scalable=no` in the viewport meta tag. *(1.4.4)*

## Images & media

- Every `<img>` has an `alt`. Decorative images get `alt=""` (not omitted —
  a missing `alt` reads out the filename in some AT). Informative images get
  alt text describing their function/content, not "image of...". *(1.1.1)*
- Complex images (charts, diagrams, infographics) get a text alternative
  covering the data/relationships, not just a caption — a long description
  nearby or linked, not crammed into `alt`. *(1.1.1)*
- Video has captions (synchronized) for all spoken/meaningful audio; prerecorded
  video-only content gets a text or audio description track. *(1.2.2, 1.2.3)*
- No content flashes more than three times per second. *(2.3.1)*
- Autoplaying audio/video longer than 3 seconds has an accessible pause/stop/
  mute control reachable before the media starts, or doesn't autoplay. *(1.4.2)*

## ARIA & dynamic content

- ARIA roles/states/properties are valid for the element they're on and kept
  in sync with actual state — a `role="button"` that never gets
  `aria-pressed`/`aria-expanded` updated on interaction is worse than no ARIA. *(4.1.2)*
- Live regions (`aria-live="polite"` for status messages, `"assertive"` only
  for urgent/blocking ones) announce dynamic content changes that aren't
  triggered by a user action on that same element — toasts, async validation,
  loading-complete states. *(4.1.3)*
- Every custom component name, role, and value is exposed programmatically
  (`aria-label`/`aria-labelledby`, `role`, `aria-valuenow` etc.) so assistive
  tech reports the same thing a sighted mouse user sees. *(4.1.2)*
- Icon-only buttons/links get an accessible name via `aria-label` or visually
  hidden text — an icon alone with no text is not labeled for AT. *(4.1.2, 2.4.4)*
- `aria-hidden="true"` never lands on a focusable element, and never hides
  content that's the only copy of information available on the page. *(4.1.2)*

## Motion & interaction

- Respect `prefers-reduced-motion`: parallax, auto-scrolling, and large
  animated transitions are disabled or substantially reduced when the user
  has this preference set. *(2.3.3)*
- Content triggered by hover or focus (tooltips, popovers) is dismissible
  without moving the pointer (e.g. `Esc`), stays visible while the pointer is
  over the trigger or the content itself, and doesn't obscure other content
  it doesn't cause. *(1.4.13)*
- Functionality available via a complex gesture (pinch, multi-finger swipe,
  drag) also has a single-pointer alternative (tap, button) unless the
  gesture is essential. *(2.5.1, 2.5.7)*
- Touch/click targets are at least 24×24 CSS px (or have sufficient spacing)
  unless the target is inline text or a native control with equivalent
  spacing. *(2.5.8)*
