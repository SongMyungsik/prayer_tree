import { useLiveQuery } from 'dexie-react-hooks'
import { useMemo } from 'react'
import { Link } from 'react-router-dom'
import { db } from '../db/db'
import CategoryPill from '../components/CategoryPill'

export default function DateViewPage() {
  const updates = useLiveQuery(() => db.updates.orderBy('date').reverse().toArray(), [], [])
  const items = useLiveQuery(() => db.items.toArray(), [], [])
  const categories = useLiveQuery(() => db.categories.toArray(), [], [])

  const itemById = useMemo(() => new Map(items.map((i) => [i.id!, i])), [items])
  const categoryById = useMemo(() => new Map(categories.map((c) => [c.id!, c])), [categories])

  const grouped = useMemo(() => {
    const map = new Map<string, typeof updates>()
    for (const u of updates) {
      const list = map.get(u.date) ?? []
      list.push(u)
      map.set(u.date, list)
    }
    return Array.from(map.entries())
  }, [updates])

  if (grouped.length === 0) {
    return (
      <p className="py-10 text-center text-sm" style={{ color: 'var(--color-text-soft)' }}>
        아직 기록된 진행 상황이 없습니다.
      </p>
    )
  }

  return (
    <div className="flex flex-col gap-6">
      {grouped.map(([date, entries]) => (
        <div key={date} className="flex flex-col gap-2">
          <h3 className="text-sm font-semibold" style={{ color: 'var(--color-accent)' }}>
            {date}
          </h3>
          <div className="flex flex-col gap-2">
            {entries.map((u) => {
              const item = itemById.get(u.itemId)
              const category = item ? categoryById.get(item.categoryId) : undefined
              return (
                <Link
                  key={u.id}
                  to={`/items/${u.itemId}`}
                  className="flex flex-col gap-1.5 rounded-xl border p-3"
                  style={{ background: 'var(--color-surface)', borderColor: 'var(--color-border)' }}
                >
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-sm font-medium" style={{ color: 'var(--color-text)' }}>
                      {item?.title ?? '(삭제된 항목)'}
                    </span>
                    {category && <CategoryPill name={category.name} color={category.color} />}
                  </div>
                  <span className="text-sm" style={{ color: 'var(--color-text-soft)' }}>
                    {u.content}
                  </span>
                </Link>
              )
            })}
          </div>
        </div>
      ))}
    </div>
  )
}
