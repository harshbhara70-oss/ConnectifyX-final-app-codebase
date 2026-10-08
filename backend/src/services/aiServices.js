import { GoogleGenAI } from "@google/genai";

console.log("Key exists:", !!process.env.GEMINI_API_KEY);
console.log("Key prefix:", process.env.GEMINI_API_KEY?.substring(0, 10));
console.log("Model:", process.env.GEMINI_MODEL);

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const MODEL = process.env.GEMINI_MODEL || "gemini-2.5-flash";

async function generateResponse(prompt) {
  try {
    const response = await ai.models.generateContent({
      model: MODEL,
      contents: prompt,
      config: {
        temperature: 0.3,
        responseMimeType: "application/json",
      },
    });

    return response.text;
  } catch (error) {
    console.error("Gemini Error:", error);
    throw new Error("Failed to generate AI response.");
  }
}

export async function generateStudyPlan(studentContext) {
  const prompt = `
You are an AI Study Planner.

Generate a 5-day study plan.

Student Context:
${studentContext}

Return ONLY valid JSON.

[
  {
    "day":"Monday",
    "tasks":["Task 1","Task 2","Task 3"]
  }
]
`;

  return generateResponse(prompt);
}

export async function analyzePlacement(studentContext) {
  const prompt = `
Analyze the student's placement readiness.

Student:
${studentContext}

Return ONLY valid JSON.

{
  "score":75,
  "strengths":["","",""],
  "gaps":["",""],
  "tip":""
}
`;

  return generateResponse(prompt);
}

export async function analyzeResume(resumeText) {
  const prompt = `
You are an ATS Resume Analyzer.

Resume:

${resumeText}

Return ONLY valid JSON.

{
  "score":82,
  "title":"",
  "description":"",
  "breakdown":[],
  "keywords_found":[],
  "keywords_missing":[],
  "tip":""
}
`;

  return generateResponse(prompt);
}

export async function analyzeSkillGap(studentContext, role) {
  const prompt = `
Target Role:
${role}

Student:
${studentContext}

Return ONLY valid JSON.

{
  "match_score":80,
  "role":"",
  "summary":"",
  "matched_skills":[],
  "missing_skills":[],
  "suggested_modules":[],
  "tip":""
}
`;

  return generateResponse(prompt);
}

export async function careerCoach(question, studentContext) {
  const prompt = `
You are an AI Career Coach.

Student Context:
${studentContext}

Question:
${question}

Return ONLY valid JSON.

{
  "answer":"Concise, practical career advice."
}
`;

  return generateResponse(prompt);
}

export async function generateResumeSummary(resume) {
  const prompt = `
You write concise, ATS-friendly resume summaries for engineering students.

Return ONLY valid JSON.

{
  "summary":""
}

Rules:
- 2-3 sentences, under 45 words total
- No first person pronouns
- Confident, specific, no empty clichés

Candidate:
${JSON.stringify(resume, null, 2)}
`;

  return generateResponse(prompt);
}

export async function enhanceResumeExperience(experience) {
  const prompt = `
You rewrite rough notes into strong, ATS-friendly resume bullet points.

Return ONLY valid JSON.

{
  "bullets":[""]
}

Rules:
- 3-4 bullets max
- Each starts with a strong action verb
- Add quantification only if implied by the notes
- Each bullet under 20 words

Experience:
${JSON.stringify(experience, null, 2)}
`;

  return generateResponse(prompt);
}

export async function classifyResumeNote(note) {
  const prompt = `
Classify this note from a student building their resume, then extract structured data.

Return ONLY valid JSON.

{
  "type":"experience",
  "experience":{"role":"","organization":"","duration":"","bullets":[""]},
  "certification":null,
  "skills":[],
  "confirmation":"Added to Experience / Projects."
}

Rules:
- "type" must be exactly one of "experience", "certification", "skill"
- Use "experience" for internships, jobs, hackathons, or projects
- Use "certification" for courses, certificates, or credentials completed
- Use "skill" for standalone tools, technologies, or languages
- Only fill the object matching the chosen type; set the others to null or empty arrays
- bullets: 2-4 short resume-style bullets built from the note
- Do not invent metrics or credentials

Student note:
${note}
`;

  return generateResponse(prompt);
}

export async function generateHiringInterview(context) {
  const prompt = `
Generate a structured mock interview for a student placement process.

Return ONLY valid JSON.

{
  "title":"",
  "rounds":[{"name":"","focus":"","durationMinutes":30,"questions":[""]}]
}

Context:
${JSON.stringify(context, null, 2)}
`;

  return generateResponse(prompt);
}

export async function generateHiringQuestions(context) {
  const prompt = `
Generate interview questions for a student hiring process.

Return ONLY valid JSON.

{
  "questions":[{"id":"q1","type":"technical","question":"","expectedSignals":[""]}]
}

Context:
${JSON.stringify(context, null, 2)}
`;

  return generateResponse(prompt);
}

export async function evaluateHiringAnswer(context) {
  const prompt = `
Evaluate a student's interview answer.

Return ONLY valid JSON.

{
  "score":75,
  "strengths":[""],
  "improvements":[""],
  "feedback":""
}

Context:
${JSON.stringify(context, null, 2)}
`;

  return generateResponse(prompt);
}

export async function generateHiringFeedback(context) {
  const prompt = `
Generate concise hiring-process feedback for a student.

Return ONLY valid JSON.

{
  "summary":"",
  "nextSteps":[""],
  "readinessScore":75
}

Context:
${JSON.stringify(context, null, 2)}
`;

  return generateResponse(prompt);
}
