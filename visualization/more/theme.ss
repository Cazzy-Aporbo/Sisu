/* theme.css
   By Cazzy
   Purpose: Example css file. Pastel design tokens and system-level CSS variables.
   Use: Import first. All other files read from these tokens.
*/

/* Root tokens: pastel spectrum, semantic roles, spacing, type scale */
:root {
  /* Pastel palette (full-spectrum, soft saturation) */
  --p-rose: #ffd6e0;
  --p-pink: #ffd1f0;
  --p-peach: #ffe5cc;
  --p-lemon: #fff2cc;
  --p-mint: #dff7ea;
  --p-aqua: #dff3ff;
  --p-sky: #e6f0ff;
  --p-peri: #e9e7ff;
  --p-lav: #f1e6ff;

  /* Neutral tokens (soft dark for text on pastel backgrounds) */
  --n-ink: #22303f;
  --n-muted: #5b6b78;
  --n-surface: #ffffff;

  /* Semantic tokens */
  --bg-page: linear-gradient(135deg, var(--p-sky), var(--p-mint));
  --card-bg: rgba(255,255,255,0.72); /* slightly translucent for glassy feel */
  --glass-blur: 10px;

  /* Spacing scale */
  --space-xxs: 4px;
  --space-xs: 8px;
  --space-sm: 12px;
  --space-md: 20px;
  --space-lg: 32px;
  --space-xl: 48px;

  /* Type scale */
  --font-sans: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
  --type-xxs: 12px;
  --type-xs: 14px;
  --type-sm: 16px;
  --type-md: 20px;
  --type-lg: 28px;
  --type-xl: 40px;

  /* Motion (durations) */
  --motion-fast: 120ms;
  --motion-mid: 320ms;
  --motion-slow: 640ms;

  /* Elevation shadows (soft, pastel tinted) */
  --shadow-soft: 0 6px 18px rgba(34,48,63,0.08);
  --shadow-glow: 0 10px 30px rgba(160,140,255,0.12);

  /* Border radius */
  --radius-sm: 8px;
  --radius-md: 16px;
  --radius-pill: 9999px;
}

/* Light / dark mode switch hooks (optional) */
@media (prefers-color-scheme: dark) {
  :root {
    --n-ink: #e8eef6;
    --n-muted: #bfcbd9;
    --card-bg: rgba(20,22,27,0.44);
    --bg-page: linear-gradient(135deg, #0e1013, #15171b);
    --shadow-soft: 0 6px 18px rgba(0,0,0,0.6);
    --shadow-glow: 0 10px 30px rgba(80,60,180,0.12);
  }
}

/* Accessibility: reduced motion respects */
@media (prefers-reduced-motion: reduce) {
  :root {
    --motion-fast: 0ms;
    --motion-mid: 0ms;
    --motion-slow: 0ms;
  }
}

/* Base type + body */
html, body {
  height: 100%;
  font-family: var(--font-sans);
  color: var(--n-ink);
  background: var(--bg-page);
  -webkit-font-smoothing:antialiased;
  -moz-osx-font-smoothing:grayscale;
  line-height: 1.35;
}

/* Small helper for pastel gradient backgrounds */
.pastel-bg {
  background-image: radial-gradient(circle at 10% 20%, var(--p-rose), transparent 20%),
                    radial-gradient(circle at 80% 80%, var(--p-mint), transparent 20%),
                    var(--bg-page);
}