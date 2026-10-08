export interface RecruiterNotification {
  id: string;
  title: string;
  message: string;
  timestamp: string;
  read: boolean;
  type?: 'info' | 'success' | 'warning' | 'error';
}

export const getRecruiterNotifications = (): RecruiterNotification[] => {
  const saved = localStorage.getItem('c2c_recruiter_notifications');
  if (saved) {
    try {
      return JSON.parse(saved);
    } catch {
      return [];
    }
  }
  return [
    {
      id: '1',
      title: 'New Application Received',
      message: 'Rahul Sharma applied for Software Development Engineer role.',
      timestamp: '10m ago',
      read: false,
      type: 'info'
    },
    {
      id: '2',
      title: 'Drive Approved',
      message: 'Apex Institute approved your campus drive schedule.',
      timestamp: '1h ago',
      read: false,
      type: 'success'
    }
  ];
};

export const pushRecruiterNotification = (title: string, message: string, type: 'info' | 'success' | 'warning' | 'error' = 'info') => {
  const current = getRecruiterNotifications();
  const newNotif: RecruiterNotification = {
    id: `notif_${Date.now()}`,
    title,
    message,
    timestamp: 'Just now',
    read: false,
    type,
  };
  const updated = [newNotif, ...current];
  localStorage.setItem('c2c_recruiter_notifications', JSON.stringify(updated));
  return newNotif;
};
