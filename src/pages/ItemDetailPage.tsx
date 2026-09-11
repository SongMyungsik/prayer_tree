import { useLiveQuery } from 'dexie-react-hooks'
import { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { db } from '../db/db'
import {
  addProgressUpdate,
  deletePrayerItem,
  deleteProgressUpdate,
  setPrayerItemStatus,
  updatePrayerItem,
} from '../db/actions'
import type { PrayerStatus } from '../types'
import { STATUS_LABEL } from '../types'
import StatusBadge from '../components/StatusBadge'
import CategoryPill from '../components/CategoryPill'
import PrayerItemForm from '../components/PrayerItemForm'

const STATUS_OPTIONS: PrayerStatus[] = ['praying', 'answered', 'paused']

export default function ItemDetailPage() {
  const { id } = useParams()
  const itemId = Number(id)
  const navigate = useNavigate()

  const item = useLiveQuery(() => db.items.get(itemId), [itemId])
  const category = useLiveQuery(
    () => (item ? db.categories.get(item.categoryId) : undefined),
    [item],
  )
  const categories = useLiveQuery(() => db.categories.orderBy('order').toArray(), [], [])
  const updates = useLiveQuery(
    () => db.updates.where('itemId').equals(itemId).reverse().sortBy('date'),
    [itemId],
    [],
  )

  const [showEdit, setShowEdit] = useState(false)
  const [newDate, setNewDate] = useState(() => new Date().toISOString().slice(0, 10))
  const [newContent, setNewContent] = useState('')

  if (!item) {
    return <p className="py-10 text-center text-sm" style={{ color: 'var(--color-text-soft)' }}>불러오는 중...</p>
  }

  return (
    <div className="flex flex-col gap-5">
      <button
        onClick={() => navigate(-1)}
        className="self-start text-sm"
        style={{ color: 'var(--color-text-soft)' }}
      >
        ← 목록으로
      </button>

      <div
        className="flex flex-col gap-3 rounded-xl border p-4"
        style={{ background: 'var(--color-surface)', borderColor: 'var(--color-border)' }}
      >
        <div className="flex items-start justify-between gap-2">
          <div className="flex flex-col gap-1">
            <h2 className="text-lg font-semibold" style={{ color: 'var(--color-text)' }}>
              {item.title}
            </h2>
            {item.personName && (
              <span className="text-sm" style={{ color: 'var(--color-text-soft)' }}>
                {item.personName}
              </span>
            )}
          </div>
          {category && <CategoryPill name={category.name} color={category.color} />}
        </div>

        {item.description && (
          <p className="text-sm whitespace-pre-wrap" style={{ color: 'var(--color-text)' }}>
            {item.description}
          </p>
        )}

        <div className="flex flex-wrap gap-2">
          {STATUS_OPTIONS.map((s) => (
            <button
              key={s}
              onClick={() => setPrayerItemStatus(itemId, s)}
              className="rounded-full border px-2.5 py-1 text-xs font-medium"
              style={{
                borderColor: item.status === s ? 'transparent' : 'var(--color-border)',
                background: item.status === s ? undefined : 'transparent',
                color: item.status === s ? undefined : 'var(--color-text-soft)',
              }}
            >
              {item.status === s ? <StatusBadge status={s} /> : STATUS_LABEL[s]}
            </button>
          ))}
        </div>

        <div className="flex gap-3 pt-1">
          <button onClick={() => setShowEdit(true)} className="text-xs font-medium" style={{ color: 'var(--color-accent)' }}>
            수정
          </button>
          <button
            onClick={async () => {
              if (confirm('이 기도 제목과 모든 진행 기록을 삭제할까요?')) {
                await deletePrayerItem(itemId)
                navigate('/')
              }
            }}
            className="text-xs font-medium"
            style={{ color: '#c0526a' }}
          >
            삭제
          </button>
        </div>
      </div>

      <div className="flex flex-col gap-3">
        <h3 className="text-sm font-semibold" style={{ color: 'var(--color-text)' }}>
          진행 기록
        </h3>

        <form
          className="flex flex-col gap-2 rounded-xl border p-3"
          style={{ background: 'var(--color-surface)', borderColor: 'var(--color-border)' }}
          onSubmit={async (e) => {
            e.preventDefault()
            if (!newContent.trim()) return
            await addProgressUpdate(itemId, newDate, newContent.trim())
            setNewContent('')
          }}
        >
          <div className="flex gap-2">
            <input
              type="date"
              value={newDate}
              onChange={(e) => setNewDate(e.target.value)}
              className="rounded-lg border px-2 py-1.5 text-sm"
              style={{ borderColor: 'var(--color-border)', background: 'var(--color-bg)', color: 'var(--color-text)' }}
            />
          </div>
          <textarea
            value={newContent}
            onChange={(e) => setNewContent(e.target.value)}
            placeholder="오늘의 기도 진행 상황을 기록해주세요"
            className="min-h-16 rounded-lg border px-3 py-2 text-sm"
            style={{ borderColor: 'var(--color-border)', background: 'var(--color-bg)', color: 'var(--color-text)' }}
          />
          <button
            type="submit"
            disabled={!newContent.trim()}
            className="self-end rounded-lg px-3 py-1.5 text-sm font-medium text-white disabled:opacity-40"
            style={{ background: 'var(--color-accent)' }}
          >
            기록 추가
          </button>
        </form>

        <ol className="flex flex-col gap-2">
          {updates.length === 0 && (
            <p className="py-4 text-center text-sm" style={{ color: 'var(--color-text-soft)' }}>
              아직 기록이 없습니다.
            </p>
          )}
          {updates.map((u) => (
            <li
              key={u.id}
              className="flex items-start justify-between gap-3 rounded-xl border p-3"
              style={{ background: 'var(--color-surface)', borderColor: 'var(--color-border)' }}
            >
              <div className="flex flex-col gap-1">
                <span className="text-xs font-medium" style={{ color: 'var(--color-accent)' }}>
                  {u.date}
                </span>
                <span className="text-sm whitespace-pre-wrap" style={{ color: 'var(--color-text)' }}>
                  {u.content}
                </span>
              </div>
              <button
                onClick={() => deleteProgressUpdate(u.id!)}
                className="text-xs"
                style={{ color: 'var(--color-text-soft)' }}
              >
                삭제
              </button>
            </li>
          ))}
        </ol>
      </div>

      {showEdit && (
        <PrayerItemForm
          categories={categories}
          initial={item}
          onClose={() => setShowEdit(false)}
          onSubmit={async (input) => {
            await updatePrayerItem(itemId, input)
            setShowEdit(false)
          }}
        />
      )}
    </div>
  )
}
