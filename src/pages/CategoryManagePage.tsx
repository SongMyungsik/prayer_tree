import { useLiveQuery } from 'dexie-react-hooks'
import { useState } from 'react'
import { db } from '../db/db'
import { createCategory, deleteCategory, updateCategory } from '../db/actions'
import type { PrayerCategory } from '../types'
import CategoryForm from '../components/CategoryForm'

export default function CategoryManagePage() {
  const categories = useLiveQuery(() => db.categories.orderBy('order').toArray(), [], [])
  const itemCounts = useLiveQuery(async () => {
    const items = await db.items.toArray()
    const counts = new Map<number, number>()
    for (const item of items) {
      counts.set(item.categoryId, (counts.get(item.categoryId) ?? 0) + 1)
    }
    return counts
  }, [], new Map<number, number>())

  const [showAdd, setShowAdd] = useState(false)
  const [editing, setEditing] = useState<PrayerCategory | null>(null)

  return (
    <div className="flex flex-col gap-3">
      <p className="text-sm" style={{ color: 'var(--color-text-soft)' }}>
        기도 제목을 분류할 카테고리를 관리합니다.
      </p>

      <div className="flex flex-col gap-2">
        {categories.map((c) => (
          <div
            key={c.id}
            className="flex items-center justify-between gap-2 rounded-xl border p-3"
            style={{ background: 'var(--color-surface)', borderColor: 'var(--color-border)' }}
          >
            <div className="flex items-center gap-2">
              <span className="h-3 w-3 rounded-full" style={{ background: c.color }} />
              <span className="text-sm font-medium" style={{ color: 'var(--color-text)' }}>
                {c.name}
              </span>
              <span className="text-xs" style={{ color: 'var(--color-text-soft)' }}>
                {itemCounts.get(c.id!) ?? 0}개
              </span>
            </div>
            <div className="flex gap-3">
              <button onClick={() => setEditing(c)} className="text-xs font-medium" style={{ color: 'var(--color-accent)' }}>
                수정
              </button>
              <button
                onClick={async () => {
                  const count = itemCounts.get(c.id!) ?? 0
                  const msg =
                    count > 0
                      ? `이 카테고리에 속한 기도 제목 ${count}개와 진행 기록도 함께 삭제됩니다. 계속할까요?`
                      : '이 카테고리를 삭제할까요?'
                  if (confirm(msg)) await deleteCategory(c.id!)
                }}
                className="text-xs"
                style={{ color: '#c0526a' }}
              >
                삭제
              </button>
            </div>
          </div>
        ))}
      </div>

      <button
        onClick={() => setShowAdd(true)}
        className="rounded-xl border border-dashed py-3 text-sm font-medium"
        style={{ borderColor: 'var(--color-border)', color: 'var(--color-accent)' }}
      >
        + 카테고리 추가
      </button>

      {showAdd && (
        <CategoryForm
          onClose={() => setShowAdd(false)}
          onSubmit={async ({ name, color }) => {
            await createCategory(name, color)
            setShowAdd(false)
          }}
        />
      )}

      {editing && (
        <CategoryForm
          initial={editing}
          onClose={() => setEditing(null)}
          onSubmit={async ({ name, color }) => {
            await updateCategory(editing.id!, { name, color })
            setEditing(null)
          }}
        />
      )}
    </div>
  )
}
