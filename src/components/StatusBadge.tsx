import type { PrayerStatus } from '../types'
import { STATUS_LABEL } from '../types'

const STYLE: Record<PrayerStatus, { bg: string; fg: string }> = {
  praying: { bg: 'var(--color-accent-soft)', fg: 'var(--color-accent)' },
  answered: { bg: 'var(--color-answered-soft)', fg: 'var(--color-answered)' },
  paused: { bg: 'var(--color-paused-soft)', fg: 'var(--color-paused)' },
}

export default function StatusBadge({ status }: { status: PrayerStatus }) {
  const style = STYLE[status]
  return (
    <span
      className="rounded-full px-2.5 py-1 text-xs font-medium whitespace-nowrap"
      style={{ background: style.bg, color: style.fg }}
    >
      {STATUS_LABEL[status]}
    </span>
  )
}
