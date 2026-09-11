import { useLiveQuery } from 'dexie-react-hooks'
import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { db } from '../db/db'
import { createPrayerItem } from '../db/actions'
import type { PrayerStatus } from '../types'
import { STATUS_LABEL } from '../types'
import CategoryPill from '../components/CategoryPill'
import StatusBadge from '../components/StatusBadge'
import PrayerItemForm from '../components/PrayerItemForm'

const STATUS_FILTERS: (PrayerStatus | 'all')[] = ['all', 'praying', 'answered', 'paused']

export default function ItemListPage() {
  const categories = useLiveQuery(() => db.categories.orderBy('order').toArray(), [], [])
  const items = useLiveQuery(() => db.items.orderBy('createdAt').reverse().toArray(), [], [])

  const [categoryFilter, setCategoryFilter] = useState<number | 'all'>('all')
  const [statusFilter, setStatusFilter] = useState<PrayerStatus | 'all'>('all')
  const [showForm, setShowForm] = useState(false)

  const categoryById = useMemo(() => new Map(categories.map((c) => [c.id!, c])), [categories])

  const filteredItems = useMemo(
    () =>
      items.filter(
        (item) =>
          (categoryFilter === 'all' || item.categoryId === categoryFilter) &&
          (statusFilter === 'all' || item.status === statusFilter),
      ),
    [items, categoryFilter, statusFilter],
  )

  if (categories.length === 0) {
    return <p className="py-10 text-center text-sm" style={{ color: 'var(--color-text-soft)' }}>불러오는 중...</p>
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => setCategoryFilter('all')}
          className="rounded-full px-3 py-1 text-xs font-medium"
          style={{
            background: categoryFilter === 'all' ? 'var(--color-accent)' : 'var(--color-surface)',
            color: categoryFilter === 'all' ? '#fff' : 'var(--color-text-soft)',
            border: '1px solid var(--color-border)',
          }}
        >
          전체
        </button>
        {categories.map((c) => (
          <button key={c.id} onClick={() => setCategoryFilter(c.id!)}>
            <span
              className="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium"
              style={{
                background: categoryFilter === c.id ? c.color : `${c.color}22`,
                color: categoryFilter === c.id ? '#fff' : c.color,
              }}
            >
              <span className="h-1.5 w-1.5 rounded-full" style={{ background: categoryFilter === c.id ? '#fff' : c.color }} />
              {c.name}
            </span>
          </button>
        ))}
      </div>

      <div className="flex gap-2">
        {STATUS_FILTERS.map((s) => (
          <button
            key={s}
            onClick={() => setStatusFilter(s)}
            className="rounded-lg px-2.5 py-1 text-xs font-medium"
            style={{
              background: statusFilter === s ? 'var(--color-accent-soft)' : 'transparent',
              color: statusFilter === s ? 'var(--color-accent)' : 'var(--color-text-soft)',
            }}
          >
            {s === 'all' ? '전체 상태' : STATUS_LABEL[s]}
          </button>
        ))}
      </div>

      <div className="flex flex-col gap-2">
        {filteredItems.length === 0 && (
          <p className="py-10 text-center text-sm" style={{ color: 'var(--color-text-soft)' }}>
            해당하는 기도 제목이 없습니다.
          </p>
        )}
        {filteredItems.map((item) => {
          const category = categoryById.get(item.categoryId)
          return (
            <Link
              key={item.id}
              to={`/items/${item.id}`}
              className="flex flex-col gap-2 rounded-xl border p-3.5 transition-colors"
              style={{ background: 'var(--color-surface)', borderColor: 'var(--color-border)' }}
            >
              <div className="flex items-start justify-between gap-2">
                <div className="flex flex-col gap-1">
                  <span className="font-medium" style={{ color: 'var(--color-text)' }}>
                    {item.title}
                  </span>
                  {item.personName && (
                    <span className="text-xs" style={{ color: 'var(--color-text-soft)' }}>
                      {item.personName}
                    </span>
                  )}
                </div>
                <StatusBadge status={item.status} />
              </div>
              {category && <CategoryPill name={category.name} color={category.color} />}
            </Link>
          )
        })}
      </div>

      <button
        onClick={() => setShowForm(true)}
        className="fixed bottom-20 right-4 flex h-14 w-14 items-center justify-center rounded-full text-2xl text-white shadow-lg"
        style={{ background: 'var(--color-accent)' }}
        aria-label="기도 제목 추가"
      >
        +
      </button>

      {showForm && (
        <PrayerItemForm
          categories={categories}
          onClose={() => setShowForm(false)}
          onSubmit={async (input) => {
            await createPrayerItem(input)
            setShowForm(false)
          }}
        />
      )}
    </div>
  )
}
