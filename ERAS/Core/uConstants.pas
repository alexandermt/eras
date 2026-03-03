unit uConstants;

interface

type
  TRankingStatus = (rsNone, rsPending, rsRanked, rsShortlisted, rsRejected);
  TWorkspaceMemberRole = (mrViewer, mrEditor, mrOwner);

const
  STATUS_STRINGS: array[TRankingStatus] of string = (
    '', 'pending', 'ranked', 'shortlisted', 'rejected'
  );

  PROGRAMME_LIST: array[0..9] of string = (
    'MBBS', 'MBChB', 'BDS', 'BNurs', 'BPharm',
    'BMedSci', 'BMBS', 'MPharm', 'BVSc', 'BSc'
  );

  APP_TITLE   = 'ERAS - Enterprise Ranking & Admissions System';
  APP_VERSION = '1.0.0';

implementation

end.
