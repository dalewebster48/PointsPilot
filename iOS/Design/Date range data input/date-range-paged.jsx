// Single-page paginated date range input
// Sections: Be vague (months) → Be flexible (slider) → Be specific (dates)
// Each section is sized to its OWN content; the next section's title peeks
// below at low opacity. Snap stops are tracked dynamically by measuring
// each section's offsetTop.

const ACCENT = window.__ACCENT__ || '#FF6B4A';
const today = new Date(2026, 3, 26);
const yearOut = new Date(2027, 3, 25);

const MONTH_SHORT = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const MONTH_LONG = ['January','February','March','April','May','June','July','August','September','October','November','December'];
const TOTAL_DAYS = 365;

function fmtDay(d) { return d ? `${MONTH_SHORT[d.getMonth()]} ${d.getDate()}` : ''; }
function addDays(d, n) { const x = new Date(d); x.setDate(x.getDate() + n); return x; }
function daysBetween(a, b) { return Math.round((b - a) / 86400000); }
function sameDay(a, b) { return a && b && a.getFullYear()===b.getFullYear() && a.getMonth()===b.getMonth() && a.getDate()===b.getDate(); }
function clamp(n, lo, hi) { return Math.max(lo, Math.min(hi, n)); }

function rollingMonths() {
  const out = [];
  for (let i = 0; i < 12; i++) {
    const d = new Date(today.getFullYear(), today.getMonth() + i, 1);
    out.push({
      idx: i,
      label: MONTH_SHORT[d.getMonth()],
      long: MONTH_LONG[d.getMonth()],
      year: d.getFullYear(),
      monthNum: d.getMonth(),
      first: i === 0 ? today : new Date(d.getFullYear(), d.getMonth(), 1),
      last: (() => {
        const endMonth = new Date(d.getFullYear(), d.getMonth() + 1, 0);
        return i === 11 ? (endMonth < yearOut ? endMonth : yearOut) : endMonth;
      })(),
    });
  }
  return out;
}
const MONTHS = rollingMonths();

// ─── Top-level page ──────────────────────────────────────────
function App() {
  const [range, setRange] = React.useState({ startDay: 14, endDay: 35 });
  const [scrollY, setScrollY] = React.useState(0);
  const scrollerRef = React.useRef(null);
  const sectionRefs = [React.useRef(null), React.useRef(null), React.useRef(null)];

  const onScroll = (e) => {
    setScrollY(e.currentTarget.scrollTop);
  };

  // Compute per-section fade based on distance between section's top and
  // current scroll position. The closer the section's top is to the
  // scroll viewport's top, the more opaque it is. This makes sections
  // smoothly fade in as they scroll into the focus position — not just
  // when snap completes.
  const tops = sectionRefs.map(r => r.current ? r.current.offsetTop : null);
  const sectionOpacities = tops.map(top => {
    if (top == null) return 1;
    const dist = Math.abs(top - scrollY);
    // 0 dist → 1.0; falls off so by ~250px away we hit the dim floor.
    const FADE_RANGE = 250;
    const t = clamp(1 - dist / FADE_RANGE, 0, 1);
    return 0.28 + 0.72 * t;
  });
  // Active section = closest to scrollY (used for hint copy + dots)
  let activeSection = 0;
  let bestDist = Infinity;
  tops.forEach((top, i) => {
    if (top == null) return;
    const d = Math.abs(top - scrollY);
    if (d < bestDist) { bestDist = d; activeSection = i; }
  });

  const jumpTo = (i) => {
    const t = scrollerRef.current;
    if (!t || !sectionRefs[i].current) return;
    t.scrollTo({ top: sectionRefs[i].current.offsetTop, behavior: 'smooth' });
  };

  const hints = [
    'Pick months you might travel in',
    'Drag the handles to set a window',
    'Pick exact dates if you know them',
  ];

  const summary = React.useMemo(() => {
    const { startDay, endDay } = range;
    if (startDay === 0 && endDay === TOTAL_DAYS) return 'Any time in the next year';
    if (startDay == null) return `Any time before ${fmtDay(addDays(today, endDay))}`;
    if (endDay == null) return `Any time after ${fmtDay(addDays(today, startDay))}`;
    const sd = addDays(today, startDay);
    const ed = addDays(today, endDay);
    if (sameDay(sd, ed)) return `On ${fmtDay(sd)}`;
    return `Between ${fmtDay(sd)} and ${fmtDay(ed)}`;
  }, [range]);

  return (
    <div style={{
      height: '100%', display: 'flex', flexDirection: 'column',
      background: '#fff', position: 'relative',
    }}>
      <TopBar />
      <div
        ref={scrollerRef}
        onScroll={onScroll}
        style={{
          flex: 1, overflowY: 'scroll', overflowX: 'hidden',
          scrollSnapType: 'y mandatory',
          scrollbarWidth: 'none',
        }}
      >
        <style>{`
          .snap-section::-webkit-scrollbar { display: none; }
          .snap-section { scroll-snap-align: start; scroll-snap-stop: always; }
        `}</style>

        <SnapSection ref={sectionRefs[0]} opacity={sectionOpacities[0]} active={activeSection === 0}>
          <MonthsInput range={range} setRange={setRange} />
        </SnapSection>
        <SnapSection ref={sectionRefs[1]} opacity={sectionOpacities[1]} active={activeSection === 1}>
          <SliderInput range={range} setRange={setRange} />
        </SnapSection>
        <SnapSection ref={sectionRefs[2]} opacity={sectionOpacities[2]} active={activeSection === 2} isLast>
          <DatesInput range={range} setRange={setRange} />
        </SnapSection>
      </div>
      <SummaryCard hint={hints[activeSection]} summary={summary} />
      <PageDots active={activeSection} onJump={jumpTo} />
    </div>
  );
}

function TopBar() {
  return (
    <div style={{
      paddingTop: 54, paddingLeft: 16, paddingRight: 16, paddingBottom: 8,
      display: 'flex', alignItems: 'center', position: 'relative', flexShrink: 0,
      zIndex: 10, background: '#fff',
    }}>
      <button style={{
        width: 36, height: 36, borderRadius: 18, border: 'none',
        background: '#F2F2F2', display: 'grid', placeItems: 'center', cursor: 'pointer',
      }}>
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path d="M15 6l-6 6 6 6" stroke="#111" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </button>
      <div style={{
        position: 'absolute', left: 0, right: 0, textAlign: 'center',
        fontSize: 17, fontWeight: 600, color: '#111', pointerEvents: 'none',
      }}>When?</div>
    </div>
  );
}

// Each section is sized to its content. Padding-bottom 24 leaves a gap
// before the next section so the peek of the next title reads as separate.
const SnapSection = React.forwardRef(function SnapSection({ active, isLast, opacity = 1, children }, ref) {
  return (
    <div ref={ref} className="snap-section" style={{
      width: '100%',
      display: 'flex', flexDirection: 'column',
      paddingBottom: isLast ? 0 : 24,
      opacity,
      pointerEvents: active ? 'auto' : 'none',
    }}>
      {children}
    </div>
  );
});

function PageDots({ active, onJump }) {
  return (
    <div style={{
      position: 'absolute', right: 10, top: 130,
      display: 'flex', flexDirection: 'column', gap: 8, zIndex: 30,
    }}>
      {[0,1,2].map(i => (
        <button key={i} onClick={() => onJump(i)} style={{
          width: 6, height: active === i ? 22 : 6,
          borderRadius: 3, border: 'none', cursor: 'pointer', padding: 0,
          background: active === i ? ACCENT : 'rgba(0,0,0,0.18)',
          transition: 'all 280ms cubic-bezier(.34,1.56,.64,1)',
        }} />
      ))}
    </div>
  );
}

// ─── Big left-aligned section title ──────────────────────────
function BigTitle({ children }) {
  return (
    <div style={{
      fontSize: 32, fontWeight: 800, color: '#111',
      letterSpacing: -1, lineHeight: 1.1,
      padding: '4px 20px 16px',
    }}>{children}</div>
  );
}

// ─── Summary card (sticky bottom) ────────────────────────────
function SummaryCard({ hint, summary }) {
  return (
    <div style={{
      flexShrink: 0,
      margin: '0 16px 28px', borderRadius: 24, background: '#FAFAFA',
      boxShadow: '0 12px 36px rgba(0,0,0,0.10), 0 2px 8px rgba(0,0,0,0.04), inset 0 0 0 1px rgba(0,0,0,0.04)',
      padding: '20px 20px 16px', zIndex: 20, position: 'relative',
    }}>
      <div style={{ fontSize: 24, fontWeight: 700, letterSpacing: -0.4, color: '#111' }}>When are you travelling?</div>
      <div key={hint} style={{
        fontSize: 13, color: '#666', marginTop: 2, minHeight: 18,
        animation: 'hintSwap 320ms cubic-bezier(.34,1.56,.64,1)',
      }}>{hint}</div>
      <div style={{ height: 1, background: 'rgba(0,0,0,0.08)', margin: '14px 0' }} />
      <div style={{
        minHeight: 28, display: 'grid', placeItems: 'center', textAlign: 'center',
        padding: '4px 8px',
      }}>
        <div key={summary} style={{
          fontSize: 17, fontWeight: 500, color: '#111', letterSpacing: -0.2,
          animation: 'summFade 240ms cubic-bezier(.34,1.56,.64,1)',
        }}>{summary}</div>
      </div>
      <div style={{ height: 1, background: 'rgba(0,0,0,0.08)', margin: '12px 0 14px' }} />
      <button style={{
        width: '100%', height: 50, borderRadius: 16, border: 'none',
        background: ACCENT, color: '#fff', fontSize: 17, fontWeight: 600,
        cursor: 'pointer', letterSpacing: -0.2,
      }}>Ok</button>
    </div>
  );
}

// ═════════════════════════════════════════════════════════════
// SECTION 1 — Be vague (months)
// ═════════════════════════════════════════════════════════════
function MonthsInput({ range, setRange }) {
  const sel = React.useMemo(() => {
    const s = new Set();
    if (range.startDay == null || range.endDay == null) return s;
    const sd = addDays(today, range.startDay);
    const ed = addDays(today, range.endDay);
    MONTHS.forEach((m, i) => {
      if (m.first <= ed && m.last >= sd) s.add(i);
    });
    return s;
  }, [range]);

  const [painting, setPainting] = React.useState(null);

  const writeFromSet = (next) => {
    if (next.size === 0) {
      setRange({ startDay: 0, endDay: TOTAL_DAYS });
      return;
    }
    const sorted = [...next].sort((a,b)=>a-b);
    const first = MONTHS[sorted[0]].first;
    const last = MONTHS[sorted[sorted.length - 1]].last;
    setRange({
      startDay: clamp(daysBetween(today, first), 0, TOTAL_DAYS),
      endDay: clamp(daysBetween(today, last), 0, TOTAL_DAYS),
    });
  };

  const toggle = (i, mode) => {
    const next = new Set(sel);
    if (mode === 'add') next.add(i);
    else if (mode === 'remove') next.delete(i);
    else next.has(i) ? next.delete(i) : next.add(i);
    writeFromSet(next);
  };

  return (
    <div>
      <BigTitle>Be vague</BigTitle>
      <div
        onPointerUp={() => setPainting(null)}
        onPointerLeave={() => setPainting(null)}
        style={{
          display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10,
          padding: '0 20px',
        }}>
        {MONTHS.map((m, i) => {
          const isSel = sel.has(i);
          return (
            <button key={i}
              onPointerDown={(e) => {
                e.preventDefault();
                const mode = isSel ? 'remove' : 'add';
                setPainting(mode);
                toggle(i, mode);
              }}
              onPointerEnter={() => { if (painting) toggle(i, painting); }}
              style={{
                height: 56, borderRadius: 18, border: 'none', cursor: 'pointer',
                background: isSel ? ACCENT : '#F4F4F5',
                color: isSel ? '#fff' : '#111',
                fontSize: 15, fontWeight: 600, letterSpacing: -0.2,
                display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
                gap: 1, transition: 'transform 160ms cubic-bezier(.34,1.56,.64,1), background 160ms ease, color 160ms',
                transform: isSel ? 'scale(1.02)' : 'scale(1)',
                touchAction: 'none', userSelect: 'none',
              }}>
              <div>{m.label}</div>
              <div style={{ fontSize: 9.5, opacity: 0.55, fontWeight: 500 }}>{m.year}</div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

// ═════════════════════════════════════════════════════════════
// SECTION 2 — Be flexible (slider)
// ═════════════════════════════════════════════════════════════
function SliderInput({ range, setRange }) {
  const [drag, setDrag] = React.useState(null);
  const ribbonRef = React.useRef(null);

  const a = range.startDay ?? 0;
  const b = range.endDay ?? TOTAL_DAYS;

  React.useEffect(() => {
    if (!drag) return;
    const move = (e) => {
      if (!ribbonRef.current) return;
      const cx = e.clientX ?? e.touches?.[0]?.clientX;
      const rect = ribbonRef.current.getBoundingClientRect();
      const pct = clamp((cx - rect.left) / rect.width, 0, 1);
      const day = Math.round(pct * TOTAL_DAYS);
      if (drag === 'a') setRange(r => ({ ...r, startDay: clamp(day, 0, (r.endDay ?? TOTAL_DAYS) - 1) }));
      else setRange(r => ({ ...r, endDay: clamp(day, (r.startDay ?? 0) + 1, TOTAL_DAYS) }));
    };
    const up = () => setDrag(null);
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
    return () => {
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
    };
  }, [drag]);

  const ticks = MONTHS.map((m) => ({
    ...m,
    pct: clamp(daysBetween(today, m.first) / TOTAL_DAYS, 0, 1),
  }));

  const sd = addDays(today, a);
  const ed = addDays(today, b);

  return (
    <div>
      <BigTitle>Be flexible</BigTitle>
      <div style={{ padding: '0 20px' }}>
        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
          padding: '0 4px',
        }}>
          <div>
            <div style={labelStyle}>From</div>
            <div style={bigDateStyle}>{fmtDay(sd)}</div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={labelStyle}>To</div>
            <div style={bigDateStyle}>{fmtDay(ed)}</div>
          </div>
        </div>

        <div ref={ribbonRef} style={{
          position: 'relative', height: 70, marginTop: 18,
          touchAction: 'none', userSelect: 'none',
        }}>
          <div style={{
            position: 'absolute', top: 26, left: 0, right: 0, height: 12,
            borderRadius: 6, background: '#F0F0F2',
          }} />
          <div style={{
            position: 'absolute', top: 26, height: 12, borderRadius: 6,
            background: ACCENT,
            left: `${(a / TOTAL_DAYS) * 100}%`,
            right: `${(1 - b / TOTAL_DAYS) * 100}%`,
            transition: drag ? 'none' : 'all 220ms cubic-bezier(.34,1.56,.64,1)',
          }} />
          {ticks.map((t, i) => (
            <div key={i} style={{
              position: 'absolute', top: 46, left: `${t.pct * 100}%`,
              transform: 'translateX(-50%)',
              fontSize: 9, color: '#aaa', fontWeight: 600, letterSpacing: 0.3,
              pointerEvents: 'none',
            }}>{t.label[0]}</div>
          ))}
          <Handle pos={a / TOTAL_DAYS} onDown={() => setDrag('a')} dragging={drag === 'a'} />
          <Handle pos={b / TOTAL_DAYS} onDown={() => setDrag('b')} dragging={drag === 'b'} />
        </div>

        <div style={{ marginTop: 14 }}>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {[
              { label: 'This weekend', a: 4, b: 6 },
              { label: 'Next month', a: 30, b: 60 },
              { label: 'Summer', a: 60, b: 150 },
              { label: 'Anytime', a: 0, b: 365 },
            ].map(p => (
              <button key={p.label}
                onClick={() => setRange({ startDay: p.a, endDay: p.b })}
                style={{
                  padding: '8px 14px', borderRadius: 999, border: 'none',
                  background: '#F4F4F5', color: '#333', fontSize: 13, fontWeight: 500,
                  cursor: 'pointer', letterSpacing: -0.1,
                }}>{p.label}</button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function Handle({ pos, onDown, dragging }) {
  return (
    <div onPointerDown={(e) => { e.preventDefault(); onDown(); }}
      style={{
        position: 'absolute', top: 18, left: `${pos * 100}%`,
        width: 28, height: 28, transform: 'translate(-50%, 0)',
        borderRadius: 14, background: '#fff', cursor: 'grab',
        boxShadow: dragging
          ? `0 0 0 6px ${ACCENT}33, 0 4px 12px rgba(0,0,0,0.12)`
          : `0 0 0 2px ${ACCENT}, 0 2px 6px rgba(0,0,0,0.1)`,
        transition: dragging ? 'box-shadow 160ms' : 'box-shadow 160ms',
        touchAction: 'none', zIndex: 5,
      }} />
  );
}

// ═════════════════════════════════════════════════════════════
// SECTION 3 — Be specific (mini year calendar)
// ═════════════════════════════════════════════════════════════
function DatesInput({ range, setRange }) {
  const startDate = range.startDay == null ? null : addDays(today, range.startDay);
  const endDate = range.endDay == null ? null : addDays(today, range.endDay);
  const [anchorMode, setAnchorMode] = React.useState('end');

  const handleDayTap = (d) => {
    const dayOff = clamp(daysBetween(today, d), 0, TOTAL_DAYS);
    if (anchorMode === 'start') {
      setRange({ startDay: dayOff, endDay: dayOff });
      setAnchorMode('end');
    } else {
      setRange(r => {
        const s = r.startDay ?? dayOff;
        if (dayOff < s) return { startDay: dayOff, endDay: s };
        return { startDay: s, endDay: dayOff };
      });
      setAnchorMode('start');
    }
  };

  return (
    <div>
      <BigTitle>Be specific</BigTitle>
      <div style={{
        display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10,
        padding: '0 16px',
      }}>
        {MONTHS.map((m, i) => (
          <MiniMonth key={i} m={m}
            range={{ start: startDate, end: endDate }}
            onDayTap={handleDayTap} />
        ))}
      </div>
    </div>
  );
}

function MiniMonth({ m, range, onDayTap }) {
  const firstDow = new Date(m.year, m.monthNum, 1).getDay();
  const offset = (firstDow + 6) % 7;
  const daysInMonth = new Date(m.year, m.monthNum + 1, 0).getDate();
  const cells = [];
  for (let i = 0; i < offset; i++) cells.push(null);
  for (let d = 1; d <= daysInMonth; d++) cells.push(new Date(m.year, m.monthNum, d));

  return (
    <div style={{ borderRadius: 12, padding: '6px 4px 4px' }}>
      <div style={{
        padding: '0 4px 4px', fontSize: 11.5, fontWeight: 700,
        color: '#111', letterSpacing: -0.1,
        display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
      }}>
        <span>{m.long}</span>
        <span style={{ fontSize: 9, color: '#bbb', fontWeight: 500 }}>{m.year}</span>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 1 }}>
        {cells.map((d, i) => {
          if (!d) return <div key={i} />;
          const tooEarly = d < today;
          const tooLate = d > yearOut;
          const disabled = tooEarly || tooLate;
          let state = 'idle';
          if (range.start && sameDay(d, range.start)) state = 'start';
          else if (range.end && sameDay(d, range.end)) state = 'end';
          else if (range.start && range.end && d > range.start && d < range.end) state = 'mid';

          return (
            <button key={i}
              disabled={disabled}
              onClick={() => !disabled && onDayTap(d)}
              style={{
                aspectRatio: '1', border: 'none', cursor: disabled ? 'default' : 'pointer',
                fontSize: 9.5, fontWeight: state === 'idle' ? 500 : 700,
                color: disabled ? '#ddd'
                     : state === 'start' || state === 'end' ? '#fff'
                     : state === 'mid' ? ACCENT
                     : '#333',
                background: state === 'start' || state === 'end' ? ACCENT
                         : state === 'mid' ? ACCENT + '22'
                         : 'transparent',
                borderRadius: state === 'start' ? '8px 4px 4px 8px'
                            : state === 'end' ? '4px 8px 8px 4px'
                            : state === 'mid' ? 4
                            : 8,
                padding: 0, transition: 'background 160ms, color 160ms',
              }}>{d.getDate()}</button>
          );
        })}
      </div>
    </div>
  );
}

const labelStyle = {
  fontSize: 11, color: '#888', textTransform: 'uppercase',
  letterSpacing: 0.6, fontWeight: 600,
};
const bigDateStyle = {
  fontSize: 22, fontWeight: 700, color: '#111', letterSpacing: -0.5, marginTop: 2,
};

Object.assign(window, { App, MONTHS, today, yearOut });
