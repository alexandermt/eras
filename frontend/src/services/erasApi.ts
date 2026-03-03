import api from './api';
import type {
  Workspace, WorkspaceCreate, Applicant, Snapshot, SnapshotDetail,
  Ranking, RankingUpsert,
} from '../types';

// --- Auth ---
export async function login(username: string, password: string) {
  const form = new URLSearchParams({ username, password });
  const { data } = await api.post('/auth/token', form, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });
  return data;
}

// --- Workspaces ---
export async function listWorkspaces(): Promise<Workspace[]> {
  const { data } = await api.get('/workspaces/');
  return data;
}

export async function createWorkspace(payload: WorkspaceCreate): Promise<Workspace> {
  const { data } = await api.post('/workspaces/', payload);
  return data;
}

export async function updateWorkspace(id: number, payload: Partial<WorkspaceCreate & { status: string }>): Promise<Workspace> {
  const { data } = await api.patch(`/workspaces/${id}`, payload);
  return data;
}

export async function deleteWorkspace(id: number): Promise<void> {
  await api.delete(`/workspaces/${id}`);
}

// --- Applicants ---
export async function listApplicants(program?: string, cycleYear?: number): Promise<Applicant[]> {
  const params: Record<string, string | number> = {};
  if (program) params.program = program;
  if (cycleYear) params.cycle_year = cycleYear;
  const { data } = await api.get('/applicants/', { params });
  return data;
}

// --- Snapshots ---
export async function listSnapshots(workspaceId: number): Promise<Snapshot[]> {
  const { data } = await api.get(`/workspaces/${workspaceId}/snapshots/`);
  return data;
}

export async function createSnapshot(workspaceId: number, label: string, description?: string): Promise<Snapshot> {
  const { data } = await api.post(`/workspaces/${workspaceId}/snapshots/`, { label, description });
  return data;
}

export async function getSnapshot(workspaceId: number, snapshotId: number): Promise<SnapshotDetail> {
  const { data } = await api.get(`/workspaces/${workspaceId}/snapshots/${snapshotId}`);
  return data;
}

// --- Rankings ---
export async function listRankings(workspaceId: number): Promise<Ranking[]> {
  const { data } = await api.get(`/workspaces/${workspaceId}/rankings/`);
  return data;
}

export async function upsertRankings(workspaceId: number, rankings: RankingUpsert[]): Promise<Ranking[]> {
  const { data } = await api.put(`/workspaces/${workspaceId}/rankings/`, rankings);
  return data;
}

// --- Export ---
export function exportRankedListUrl(workspaceId: number): string {
  return `/api/workspaces/${workspaceId}/export/ranked-list`;
}
