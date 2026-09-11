import { useState } from 'react'
import type { PrayerCategory, PrayerItem } from '../types'
import Modal from './Modal'

export default function PrayerItemForm({
  categories,
  initial,
  onClose,
  onSubmit,
}: {
  categories: PrayerCategory[]
  initial?: PrayerItem
  onClose: () => void
  onSubmit: (input: { categoryId: number; title: string; personName?: string; description?: string }) => void
}) {
  const [categoryId, setCategoryId] = useState<number>(initial?.categoryId ?? categories[0]?.id ?? 0)
  const [title, setTitle] = useState(initial?.title ?? '')
  const [personName, setPersonName] = useState(initial?.personName ?? '')
  const [description, setDescription] = useState(initial?.description ?? '')

  const canSubmit = title.trim().length > 0 && categoryId > 0

  return (
    <Modal title={initial ? '기도 제목 수정' : '기도 제목 추가'} onClose={onClose}>
      <form
        className="flex flex-col gap-4"
        onSubmit={(e) => {
          e.preventDefault()
          if (!canSubmit) return
          onSubmit({
            categoryId,
            title: title.trim(),
            personName: personName.trim() || undefined,
            description: description.trim() || undefined,
          })
        }}
      >
        <label className="flex flex-col gap-1 text-sm" style={{ color: 'var(--color-text-soft)' }}>
          유형
          <select
            className="rounded-lg border px-3 py-2 text-sm"
            style={{ borderColor: 'var(--color-border)', background: 'var(--color-bg)', color: 'var(--color-text)' }}
            value={categoryId}
            onChange={(e) => setCategoryId(Number(e.target.value))}
          >
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
        </label>

        <label className="flex flex-col gap-1 text-sm" style={{ color: 'var(--color-text-soft)' }}>
          제목 *
          <input
            className="rounded-lg border px-3 py-2 text-sm"
            style={{ borderColor: 'var(--color-border)', background: 'var(--color-bg)', color: 'var(--color-text)' }}
            placeholder="예: OO 집사님 건강 회복"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            autoFocus
          />
        </label>

        <label className="flex flex-col gap-1 text-sm" style={{ color: 'var(--color-text-soft)' }}>
          대상자 (선택)
          <input
            className="rounded-lg border px-3 py-2 text-sm"
            style={{ borderColor: 'var(--color-border)', background: 'var(--color-bg)', color: 'var(--color-text)' }}
            placeholder="이름 또는 관계"
            value={personName}
            onChange={(e) => setPersonName(e.target.value)}
          />
        </label>

        <label className="flex flex-col gap-1 text-sm" style={{ color: 'var(--color-text-soft)' }}>
          설명 (선택)
          <textarea
            className="min-h-20 rounded-lg border px-3 py-2 text-sm"
            style={{ borderColor: 'var(--color-border)', background: 'var(--color-bg)', color: 'var(--color-text)' }}
            placeholder="기도 배경, 상황 등을 적어주세요"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </label>

        <button
          type="submit"
          disabled={!canSubmit}
          className="rounded-lg py-2.5 text-sm font-medium text-white disabled:opacity-40"
          style={{ background: 'var(--color-accent)' }}
        >
          {initial ? '수정 완료' : '추가하기'}
        </button>
      </form>
    </Modal>
  )
}
