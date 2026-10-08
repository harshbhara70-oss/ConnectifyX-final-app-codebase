import React, { useState } from "react";
import { CollegeSidebar } from "../components/dashboard/college/CollegeSidebar";
import type { ViewType } from "../components/dashboard/college/CollegeSidebar";
import { CollegeHeader } from "../components/dashboard/college/CollegeHeader";

// View components
import { ExecutiveOverview } from "../components/dashboard/college/views/ExecutiveOverview";
import { StudentRecordsView } from "../components/dashboard/college/views/StudentRecordsView";
import { DepartmentsView } from "../components/dashboard/college/views/DepartmentsView";
import { PlacementManagementView } from "../components/dashboard/college/views/PlacementManagementView";
import { RecruiterCoordinationView } from "../components/dashboard/college/views/RecruiterCoordinationView";
import { JobsView } from "../components/dashboard/college/views/JobsView";
import { ReadinessView } from "../components/dashboard/college/views/ReadinessView";
import { AtRiskView } from "../components/dashboard/college/views/AtRiskView";
import { ForecastView } from "../components/dashboard/college/views/ForecastView";
import { ComparisonsView } from "../components/dashboard/college/views/ComparisonsView";
import { AssessmentsView } from "../components/dashboard/college/views/AssessmentsView";
import { MentorsView } from "../components/dashboard/college/views/MentorsView";
import { ReportsAnalyticsView } from "../components/dashboard/college/views/ReportsAnalyticsView";
import { BroadcastCenterView } from "../components/dashboard/college/views/BroadcastCenterView";
import { SettingsView } from "../components/dashboard/college/views/SettingsView";
import { X, Plus, Sparkles, Download, CheckCircle2 } from "lucide-react";

export const CollegeDashboard: React.FC = () => {
  const [activeView, setActiveView] = useState<ViewType>("dashboard");
  const [searchQuery, setSearchQuery] = useState("");
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

  // Modals state
  const [isNewDriveModalOpen, setIsNewDriveModalOpen] = useState(false);
  const [isQuickActionModalOpen, setIsQuickActionModalOpen] = useState(false);
  const [isExportModalOpen, setIsExportModalOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // New Drive form state
  const [newDrive, setNewDrive] = useState({
    companyName: "",
    jobRole: "",
    packageLPA: "",
    driveDate: "",
    eligibleBranches: ["CSE", "ECE", "IT"]
  });

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => {
      setToastMessage(null);
    }, 4000);
  };

  const handleCreateDriveSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newDrive.companyName || !newDrive.jobRole) return;
    setIsNewDriveModalOpen(false);
    showToast(`Placement Drive for ${newDrive.companyName} (${newDrive.jobRole}) scheduled successfully!`);
    setNewDrive({
      companyName: "",
      jobRole: "",
      packageLPA: "",
      driveDate: "",
      eligibleBranches: ["CSE", "ECE", "IT"]
    });
  };

  // Render sub-view
  const renderCurrentView = () => {
    switch (activeView) {
      case "dashboard":
        return (
          <ExecutiveOverview
            onNavigateView={(view) => setActiveView(view)}
            onOpenNewDriveModal={() => setIsNewDriveModalOpen(true)}
            onExportReport={() => setIsExportModalOpen(true)}
            searchQuery={searchQuery}
          />
        );
      case "students":
        return <StudentRecordsView />;
      case "departments":
        return <DepartmentsView />;
      case "placement-cell":
        return <PlacementManagementView />;
      case "companies":
        return <RecruiterCoordinationView />;
      case "jobs":
        return <JobsView />;
      case "readiness":
        return <ReadinessView />;
      case "at-risk":
        return <AtRiskView />;
      case "forecast":
        return <ForecastView />;
      case "comparisons":
        return <ComparisonsView />;
      case "assessments":
        return <AssessmentsView />;
      case "mentors":
        return <MentorsView />;
      case "reports":
        return <ReportsAnalyticsView />;
      case "broadcasts":
      case "communications":
        return <BroadcastCenterView />;
      case "settings":
        return <SettingsView />;
      default:
        return (
          <ExecutiveOverview
            onNavigateView={(view) => setActiveView(view)}
            onOpenNewDriveModal={() => setIsNewDriveModalOpen(true)}
            onExportReport={() => setIsExportModalOpen(true)}
            searchQuery={searchQuery}
          />
        );
    }
  };

  return (
    <div className="min-h-screen bg-[#F4F5FA] font-sans antialiased text-slate-900 flex">
      {/* Sidebar Navigation Container */}
      <CollegeSidebar
        activeView={activeView}
        onSelectView={(view) => setActiveView(view)}
        onNewDriveClick={() => setIsNewDriveModalOpen(true)}
        isMobileOpen={isMobileSidebarOpen}
        onCloseMobile={() => setIsMobileSidebarOpen(false)}
      />

      {/* Main Content Workspace Container */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Header Bar */}
        <CollegeHeader
          searchQuery={searchQuery}
          onSearchChange={(q) => setSearchQuery(q)}
          onQuickActionClick={() => setIsQuickActionModalOpen(true)}
          onOpenMobileSidebar={() => setIsMobileSidebarOpen(true)}
        />

        {/* Dynamic Workspace Container */}
        <main className="flex-1 p-4 md:p-6 lg:p-8 max-w-[1600px] w-full mx-auto">
          {renderCurrentView()}
        </main>
      </div>

      {/* Global Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 bg-slate-900 text-white text-xs font-semibold px-4 py-3 rounded-2xl shadow-2xl flex items-center gap-3 border border-slate-800 animate-bounce">
          <CheckCircle2 className="w-5 h-5 text-emerald-400" />
          <span>{toastMessage}</span>
          <button onClick={() => setToastMessage(null)} className="text-slate-400 hover:text-white">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Modal: New Placement Drive */}
      {isNewDriveModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                  +
                </div>
                <h3 className="text-lg font-extrabold text-slate-900">Schedule New Placement Drive</h3>
              </div>
              <button
                onClick={() => setIsNewDriveModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateDriveSubmit} className="space-y-4">
              <div>
                <label className="text-xs font-bold text-slate-700 block mb-1">Company Name</label>
                <input
                  type="text"
                  required
                  value={newDrive.companyName}
                  onChange={(e) => setNewDrive({ ...newDrive, companyName: e.target.value })}
                  placeholder="e.g. Stripe Tech / Google APAC"
                  className="w-full text-xs p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-xs font-bold text-slate-700 block mb-1">Job Role</label>
                  <input
                    type="text"
                    required
                    value={newDrive.jobRole}
                    onChange={(e) => setNewDrive({ ...newDrive, jobRole: e.target.value })}
                    placeholder="e.g. Full Stack Engineer"
                    className="w-full text-xs p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 block mb-1">Package (LPA)</label>
                  <input
                    type="text"
                    required
                    value={newDrive.packageLPA}
                    onChange={(e) => setNewDrive({ ...newDrive, packageLPA: e.target.value })}
                    placeholder="e.g. 18.5"
                    className="w-full text-xs p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="text-xs font-bold text-slate-700 block mb-1">Drive Date</label>
                <input
                  type="date"
                  required
                  value={newDrive.driveDate}
                  onChange={(e) => setNewDrive({ ...newDrive, driveDate: e.target.value })}
                  className="w-full text-xs p-3 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-purple-500/30 outline-none"
                />
              </div>

              <div className="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
                <button
                  type="button"
                  onClick={() => setIsNewDriveModalOpen(false)}
                  className="text-xs font-semibold text-slate-600 px-4 py-2.5 hover:bg-slate-100 rounded-xl"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="text-xs font-bold bg-purple-600 hover:bg-purple-700 text-white px-5 py-2.5 rounded-xl shadow-md shadow-purple-500/20"
                >
                  Schedule Drive
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Quick Action */}
      {isQuickActionModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-lg font-bold text-slate-900">Quick Actions Hub</h3>
              <button onClick={() => setIsQuickActionModalOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => {
                  setIsQuickActionModalOpen(false);
                  setIsNewDriveModalOpen(true);
                }}
                className="p-4 bg-purple-50 hover:bg-purple-100 text-purple-700 rounded-xl border border-purple-200 text-left font-bold text-xs flex flex-col gap-2 transition-all"
              >
                <Plus className="w-5 h-5 text-purple-600" />
                <span>New Drive</span>
              </button>

              <button
                onClick={() => {
                  setIsQuickActionModalOpen(false);
                  setActiveView("students");
                }}
                className="p-4 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 rounded-xl border border-indigo-200 text-left font-bold text-xs flex flex-col gap-2 transition-all"
              >
                <Sparkles className="w-5 h-5 text-indigo-600" />
                <span>Check Readiness</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Export Report */}
      {isExportModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 backdrop-blur-xs z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 className="text-lg font-bold text-slate-900">Export Placement Intelligence Report</h3>
              <button onClick={() => setIsExportModalOpen(false)} className="text-slate-400 hover:text-slate-600">
                <X className="w-5 h-5" />
              </button>
            </div>

            <p className="text-xs text-slate-600 leading-relaxed">
              Select format to export the 2026 Executive Placement Summary including company participation, offer counts, and student readiness metrics.
            </p>

            <div className="flex gap-3">
              <button
                onClick={() => {
                  setIsExportModalOpen(false);
                  showToast("PDF Executive Report downloaded successfully!");
                }}
                className="flex-1 py-3 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-xl text-xs flex items-center justify-center gap-2 shadow-md"
              >
                <Download className="w-4 h-4" /> Export PDF
              </button>
              <button
                onClick={() => {
                  setIsExportModalOpen(false);
                  showToast("Excel Raw Dataset exported successfully!");
                }}
                className="flex-1 py-3 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-xs flex items-center justify-center gap-2 shadow-md"
              >
                <Download className="w-4 h-4" /> Export Excel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CollegeDashboard;
