import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { listWorkspaces, createWorkspace, deleteWorkspace } from '../services/erasApi';
import { useAuthStore } from '../store/authStore';
import type { Workspace } from '../types';
import styles from './WorkspacesPage.module.css';

export default function WorkspacesPage() {
  const { hasRole } = useAuthStore();
  const canWrite = hasRole('admin') || hasRole('selector');
  const canDelete = hasRole('admin');

  const [workspaces, setWorkspaces] = useState<Workspace[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [newName, setNewName] = useState('');
  const [newYear, setNewYear] = useState(new Date().getFullYear());
  const [newDesc, setNewDesc] = useState('');
  const [error, setError] = useState('');

  const load = async () => {
    setLoading(true);
    try {
      setWorkspaces(await listWorkspaces());
    } catch {
      setError('Failed to load workspaces');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await createWorkspace({ name: newName, cycle_year: newYear, description: newDesc || undefined });
      setShowForm(false);
      setNewName(''); setNewYear(new Date().getFullYear()); setNewDesc('');
      load();
    } catch {
      setError('Failed to create workspace');
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this workspace? This cannot be undone.')) return;
    try {
      await deleteWorkspace(id);
      load();
    } catch {
      setError('Failed to delete workspace');
    }
  };

  return (
    <div>
      <div className={styles.pageHeader}>
        <h2>Workspaces</h2>
        {canWrite && (
          <button className={styles.primaryBtn} onClick={() => setShowForm((v) => !v)}>
            {showForm ? 'Cancel' : '+ New Workspace'}
          </button>
        )}
      </div>

      {error && <p className={styles.error}>{error}</p>}

      {showForm && (
        <form onSubmit={handleCreate} className={styles.form}>
          <input
            placeholder="Name"
            value={newName}
            onChange={(e) => setNewName(e.target.value)}
            required
            className={styles.input}
          />
          <input
            type="number"
            placeholder="Cycle Year"
            value={newYear}
            onChange={(e) => setNewYear(Number(e.target.value))}
            required
            className={styles.input}
          />
          <input
            placeholder="Description (optional)"
            value={newDesc}
            onChange={(e) => setNewDesc(e.target.value)}
            className={styles.input}
          />
          <button type="submit" className={styles.primaryBtn}>Create</button>
        </form>
      )}

      {loading ? (
        <p className={styles.loading}>Loading…</p>
      ) : (
        <div className={styles.grid}>
          {workspaces.map((ws) => (
            <div key={ws.id} className={styles.card}>
              <div className={styles.cardHeader}>
                <span className={styles.cardTitle}>{ws.name}</span>
                <span className={`${styles.badge} ${ws.status === 'active' ? styles.active : styles.archived}`}>
                  {ws.status}
                </span>
              </div>
              <p className={styles.cardMeta}>{ws.cycle_year} · Created by {ws.created_by}</p>
              {ws.description && <p className={styles.cardDesc}>{ws.description}</p>}
              <div className={styles.cardActions}>
                <Link to={`/workspaces/${ws.id}`} className={styles.linkBtn}>Open</Link>
                {canDelete && (
                  <button onClick={() => handleDelete(ws.id)} className={styles.dangerBtn}>Delete</button>
                )}
              </div>
            </div>
          ))}
          {workspaces.length === 0 && <p className={styles.empty}>No workspaces yet.</p>}
        </div>
      )}
    </div>
  );
}
