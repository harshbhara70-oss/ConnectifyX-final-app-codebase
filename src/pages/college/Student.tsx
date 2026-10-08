import { useAuth } from "../../context/AuthContext";
import CollegeLayout from "../../components/college/CollegeLayout";

import { Icon, type IconName } from "../../components/college/CollegeIcons";

const sidebarItems = [
  { label: "Dashboard", icon: "dashboard" as IconName, route: "/college-dashboard" },
  { label: "Student Management", icon: "users" as IconName, route: "/college/students-management" },
  { label: "Recruiter Management", icon: "building" as IconName, route: "/college/recruiter-management" },
  { label: "Placement Statistics", icon: "briefcase" as IconName, route: "/college/placement-statistics", badge: 5 },
  { label: "Notifications", icon: "bell" as IconName, route: "/college/notifications", badge: 3 },
  { label: "Profile", icon: "settings" as IconName, route: "/college/profile" },
  { label: "Setting", icon: "settings" as IconName, route: "/college/setting" },
];

export const CollegeStudentManagement = () => {
  const { currentUser } = useAuth();
  const fullName = currentUser?.fullName || "BITS Pilani Placement Cell Admin";

  const students = [
    { name: "Aditya Sharma", branch: "CSE", cgpa: "9.2", status: "Placed", company: "Google", badges: 4 },
    { name: "Rohan Verma", branch: "ECE", cgpa: "8.5", status: "Eligible", company: "-", badges: 2 },
    { name: "Sneha Reddy", branch: "CSE", cgpa: "9.6", status: "Placed", company: "Microsoft", badges: 5 },
    { name: "Priya Patel", branch: "ME", cgpa: "7.8", status: "Eligible", company: "-", badges: 1 },
    { name: "Kunal Sen", branch: "IT", cgpa: "8.1", status: "In-Progress", company: "-", badges: 3 },
  ];

  return (
    <CollegeLayout
      sidebarItems={sidebarItems}
      sidebarHighlight="Student Management"
      userSummary={{ fullName, role: "Training & Placement Officer", status: "Placement cycle active" }}
    >
      <div className="space-y-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
          <div>
            <h1 className="text-xl font-black text-slate-900">Student Placement Cohort</h1>
            <p className="text-sm text-slate-500 mt-1">Review active student placement status and validated skill profiles.</p>
          </div>
          <div className="relative w-full md:w-64">
            <span className="absolute inset-y-0 left-0 pl-3 flex items-center text-slate-400">
              <Icon name="search" className="h-4 w-4" />
            </span>
            <input
              type="text"
              placeholder="Search students..."
              className="w-full pl-9 pr-4 py-2 border border-slate-200 rounded-xl text-xs font-semibold focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>

        {/* Students Table */}
        <div className="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm text-slate-500 border-collapse">
              <thead className="bg-slate-50 text-[10px] font-extrabold uppercase tracking-wider text-slate-400 border-b border-slate-100">
                <tr>
                  <th className="px-6 py-4">Student Name</th>
                  <th className="px-6 py-4">Branch</th>
                  <th className="px-6 py-4">CGPA</th>
                  <th className="px-6 py-4">Badges</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4">Company</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 font-semibold text-slate-700">
                {students.map((student, idx) => (
                  <tr key={idx} className="hover:bg-slate-50/50">
                    <td className="px-6 py-4 flex items-center gap-2">
                      <div className="h-7 w-7 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center text-[10px] font-extrabold">
                        {student.name.split(" ").map(n => n[0]).join("")}
                      </div>
                      <span className="font-bold text-slate-900">{student.name}</span>
                    </td>
                    <td className="px-6 py-4">{student.branch}</td>
                    <td className="px-6 py-4">{student.cgpa}</td>
                    <td className="px-6 py-4">
                      <span className="inline-flex items-center gap-1 bg-yellow-50 text-yellow-755 border border-yellow-100 px-2 py-0.5 rounded-full text-[10px] font-black">
                        ⭐ {student.badges} badges
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold ${
                        student.status === "Placed" ? "bg-emerald-50 text-emerald-700" :
                        student.status === "In-Progress" ? "bg-amber-50 text-amber-700" : "bg-slate-100 text-slate-600"
                      }`}>
                        {student.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 font-bold text-slate-900">{student.company}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </CollegeLayout>
  );
};

export default CollegeStudentManagement;
