const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

exports.contactSubmit = onRequest(
    {region: "asia-south1", cors: true},
    async (req, res) => {
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }

      if (req.method !== "POST") {
        res.status(405).json({error: "Method not allowed"});
        return;
      }

      const body = req.body ?? {};
      const name = typeof body.name === "string" ? body.name.trim() : "";
      const email = typeof body.email === "string" ? body.email.trim() : "";
      const message = typeof body.message === "string" ?
        body.message.trim() :
        "";
      const source = typeof body.source === "string" ? body.source : "unknown";
      const submittedAt = typeof body.submittedAt === "string" ?
        body.submittedAt :
        new Date().toISOString();

      const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
      if (!name || !email || !message || !emailRegex.test(email)) {
        res.status(400).json({error: "Invalid request payload"});
        return;
      }

      try {
        const docRef = await admin
            .firestore()
            .collection("portfolioMessages")
            .add({
              name,
              email,
              message,
              source,
              submittedAt,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

        res.status(201).json({ok: true, id: docRef.id});
      } catch (error) {
        logger.error("Failed to save contact message", error);
        res.status(500).json({error: "Failed to save message"});
      }
    },
);
