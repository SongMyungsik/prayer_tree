import { useState } from 'react'
import type { PrayerCategory } from '../types'
import Modal from './Modal'

const PRESET_COLORS = ['#e0708a', '#5b8fd6', '#5aab8f', '#c98fd6', '#d69a5b', '#8a8794', '#d65b5b', '#5bc0c9']

export default function CategoryForm({
  initial,
  onClose,
  onSubmit,
}: {
  initial?: PrayerCategory
  onClose: () => void
  onSubmit: (input: { name: string; color: string }) => void
}) {
  const [name, setName] = useState(initial?.name ?? '')
  const [color, setColor] = useState(initial?.color ?? PRESET_COLORS[0])

  return (
    <Modal title={initial ? '카테고리 수정' : '카테고리 추가'} onClose={onClose}>
      <form
        className="flex flex-col gap-4"
        onSubmit={(e) => {
          e.preventDefault()
          if (!name.trim()) return
          onSubmit({ name: name.trim(), color })
        }}
      >
        <label className="flex flex-col gap-1 text-sm" style={{ color: 'var(--color-text-soft)' }}>
          이름 *
          <input
            className="rounded-lg border px-3 py-2 text-sm"
            style={{ borderColor: 'var(--color-border)', background: 'var(--color-bg)', color: 'var(--color-text)' }}
            placeholder="예: 선교사"
            value={name}
            onChange={(e) => setName(e.target.value)}
            autoFocus
          />
        </label>

        <div className="flex flex-col gap-1 text-sm" style={{ color: 'var(--color-text-soft)' }}>
          색상
          <div className="flex flex-wrap gap-2">
            {PRESET_COLORS.map((c) => (
              <button
                key={c}
                type="button"
                onClick={() => setColor(c)}
                className="h-8 w-8 rounded-full"
                style={{ background: c, outline: color === c ? `2px solid ${c}` : 'none', outlineOffset: 2 }}
                aria-label={c}
              />
            ))}
          </div>
        </div>

        <button
          type="submit"
          disabled={!name.trim()}
          className="rounded-lg py-2.5 text-sm font-medium text-white disabled:opacity-40"
          style={{ background: 'var(--color-accent)' }}
        >
          {initial ? '수정 완료' : '추가하기'}
        </button>
      </form>
    </Modal>
  )
}
