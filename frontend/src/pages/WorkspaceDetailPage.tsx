import React, { useEffect, useState, useCallback } from 'react';
import { useParams, Link } from 'react-router-dom';
import {
  listSnapshots, createSnapshot, listRankings, upsertRankings, exportRankedListUrl,
} from '../services/erasApi';
import { useAuthStore } from '../store/authStore';
import type { Snapshot, Ranking } from '../types';
import styles from './WorkspaceDetailPage.module.css';

export default function WorkspaceDetailPage() {
  const { id } = useParams<{ id: string }>();
  const workspaceId = Number(id);
  const { hasRole, token } = useAuthStore();
  const canWrite = hasRole('admin') || hasRole('selector');

  const [snapshots, setSnapshots] = useState<Snapshot[]>([]);
  const [rankings, setRankings] = useState<Ranking[]>([]);
  const [snapshotLabel, setSnapshotLabel] = useState('');
  const [snapshotDesc, setSnapshotDesc] = useState('');
  const [error, setError] = useState('');
  const [tab, setTab] = useState<'rankings' | 'snapshots'>('rankings');

  const loadSnapshots = useCallback(async () => {
    try { setSnapshots(await listSnapshots(workspaceId)); } catch { /* ignore */ }
  }, [workspaceId]);

  const loadRankings = useCallback(async () => {
    try { setRankings(await listRankings(workspaceId)); } catch { /* ignore */ }
  }, [workspaceId]);

  useEffect(() => {
    loadSnapshots();
    loadRankings();
  }, [loadSnapshots, loadRankings]);

  const handleCreateSnapshot = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await createSnapshot(workspaceId, snapshotLabel, snapshotDesc || undefined);
      setSnapshotLabel(''); setSnapshotDesc('');
      loadSnapshots();
    } catch {
      setError('Failed to create snapshot');
    }
  };

  const handleRankMove = (index: number, direction: 'up' | 'down') => {
    const newRankings = [...rankings];
    const swap = direction === 'up' ? index - 1 : index + 1;
    if (swap < 0 || swap >= newRankings.length) return;
    [newRankings[index], newRankings[swap]] = [newRankings[swap], newRankings[index]];
    setRankings(newRankings.map((r, i) => ({ ...r, rank: i + 1 })));
  };

  const handleSaveRankings = async () => {
    try {
      const payload = rankings.map((r, i) => ({
        applicant_id: r.applicant_id,
        rank: i + 1,
        score: r.score,
        notes: r.notes,
      }));
      await upsertRankings(workspaceId, payload);
      loadRankings();
    } catch {
      setError('Failed to save rankings');
    }
  };

  const exportUrl = `${exportRankedListUrl(workspaceId)}`;

  return (
    <div>
      <div className={styles.breadcrumb}>
        <Link to="/">Workspaces</Link> / Workspace #{workspaceId}
      </div>

      {error && <p className={styles.error}>{error}</p>}

      <div className={styles.tabs}>
        <button
          className={`${styles.tab} ${tab === 'rankings' ? styles.activeTab : ''}`}
          onClick={() => setTab('rankings')}
        >
          Rankings
        </button>
        <button
          className={`${styles.tab} ${tab === 'snapshots' ? styles.activeTab : ''}`}
          onClick={() => setTab('snapshots')}
        >
          Snapshots
        </button>
      </div>

      {tab === 'rankings' && (
        <div>
          <div className={styles.sectionHeader}>
            <h3>Ranked Applicants</h3>
            <div className={styles.actions}>
              {canWrite && (
                <button onClick={handleSaveRankings} className={styles.primaryBtn}>
                  Save Rankings
                </button>
              )}
              <a
                href={exportUrl}
                target="_blank"
                rel="noreferrer"
                className={styles.exportBtn}
                onClick={(e) => {
                  // Attach token via header is not possible with plain <a>, so use fetch
                  e.preventDefault();
                  fetch(exportUrl, { headers: { Authorization: `Bearer ${token}` } })
                    .then((r) => r.blob())
                    .then((blob) => {
                      const url = URL.createObjectURL(blob);
                      const a = document.createElement('a');
                      a.href = url;
                      a.download = `workspace_${workspaceId}_ranked.xlsx`;
                      a.click();
                    });
                }}
              >
                Export Excel
              </a>
            </div>
          </div>
          {rankings.length === 0 ? (
            <p className={styles.empty}>No rankings yet.</p>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>Rank</th>
                  <th>Applicant ID</th>
                  <th>Score</th>
                  <th>Notes</th>
                  {canWrite && <th>Move</th>}
                </tr>
              </thead>
              <tbody>
                {rankings.map((r, i) => (
                  <tr key={r.applicant_id}>
                    <td className={styles.rankCell}>{r.rank}</td>
                    <td>{r.applicant_id}</td>
                    <td>{r.score ?? '—'}</td>
                    <td>{r.notes ?? '—'}</td>
                    {canWrite && (
                      <td>
                        <button onClick={() => handleRankMove(i, 'up')} disabled={i === 0}>▲</button>
                        {' '}
                        <button onClick={() => handleRankMove(i, 'down')} disabled={i === rankings.length - 1}>▼</button>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}

      {tab === 'snapshots' && (
        <div>
          <div className={styles.sectionHeader}>
            <h3>Snapshots</h3>
          </div>
          {canWrite && (
            <form onSubmit={handleCreateSnapshot} className={styles.form}>
              <input
                placeholder="Snapshot label"
                value={snapshotLabel}
                onChange={(e) => setSnapshotLabel(e.target.value)}
                required
                className={styles.input}
              />
              <input
                placeholder="Description (optional)"
                value={snapshotDesc}
                onChange={(e) => setSnapshotDesc(e.target.value)}
                className={styles.input}
              />
              <button type="submit" className={styles.primaryBtn}>Create Snapshot</button>
            </form>
          )}
          {snapshots.length === 0 ? (
            <p className={styles.empty}>No snapshots yet.</p>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>#</th>
                  <th>Label</th>
                  <th>Description</th>
                  <th>Created By</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                {snapshots.map((s) => (
                  <tr key={s.id}>
                    <td>{s.id}</td>
                    <td>{s.label}</td>
                    <td>{s.description ?? '—'}</td>
                    <td>{s.created_by}</td>
                    <td>{new Date(s.created_at).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}
    </div>
  );
}
