export interface TokenResponse {
  access_token: string;
  token_type: string;
  username: string;
  display_name: string;
  roles: string[];
}

export interface Workspace {
  id: number;
  name: string;
  description?: string;
  cycle_year: number;
  status: 'active' | 'archived';
  created_by: string;
  created_at: string;
  updated_at: string;
}

export interface WorkspaceCreate {
  name: string;
  description?: string;
  cycle_year: number;
}

export interface Applicant {
  applicant_id: string;
  first_name: string;
  last_name: string;
  email?: string;
  program?: string;
  status?: string;
  gpa?: number;
  usmle_step1?: number;
  usmle_step2?: number;
}

export interface Snapshot {
  id: number;
  workspace_id: number;
  label: string;
  description?: string;
  created_by: string;
  created_at: string;
}

export interface SnapshotDetail extends Snapshot {
  applicant_data: Applicant[];
}

export interface Ranking {
  id: number;
  workspace_id: number;
  applicant_id: string;
  rank: number;
  score?: number;
  notes?: string;
  ranked_by: string;
  updated_at: string;
}

export interface RankingUpsert {
  applicant_id: string;
  rank: number;
  score?: number;
  notes?: string;
}
