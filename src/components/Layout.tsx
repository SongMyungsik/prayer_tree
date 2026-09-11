import { NavLink, Outlet } from 'react-router-dom'

const tabs = [
  { to: '/', label: '목록', end: true },
  { to: '/dates', label: '날짜별', end: false },
  { to: '/categories', label: '카테고리', end: false },
]

export default function Layout() {
  return (
    <div className="min-h-screen flex flex-col" style={{ background: 'var(--color-bg)' }}>
      <header
        className="sticky top-0 z-10 border-b px-4 py-3"
        style={{ background: 'var(--color-surface)', borderColor: 'var(--color-border)' }}
      >
        <div className="mx-auto max-w-xl">
          <h1 className="text-lg font-semibold" style={{ color: 'var(--color-text)' }}>
            🌳 기도 나무
          </h1>
        </div>
      </header>

      <main className="mx-auto w-full max-w-xl flex-1 px-4 py-4 pb-24">
        <Outlet />
      </main>

      <nav
        className="fixed bottom-0 left-0 right-0 border-t"
        style={{ background: 'var(--color-surface)', borderColor: 'var(--color-border)' }}
      >
        <div className="mx-auto flex max-w-xl">
          {tabs.map((tab) => (
            <NavLink
              key={tab.to}
              to={tab.to}
              end={tab.end}
              className={({ isActive }) =>
                `flex-1 py-3 text-center text-sm font-medium transition-colors ${
                  isActive ? '' : ''
                }`
              }
              style={({ isActive }) => ({
                color: isActive ? 'var(--color-accent)' : 'var(--color-text-soft)',
              })}
            >
              {tab.label}
            </NavLink>
          ))}
        </div>
      </nav>
    </div>
  )
}
