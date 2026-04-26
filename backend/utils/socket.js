const { Server } = require("socket.io");
const jwt = require("jsonwebtoken");
const chatService = require("../services/chat.service");
const familyService = require("../services/family.service");

const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret_key";

let io;

const setSocketIO = (server) => {
  io = new Server(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST", "PATCH", "PUT", "DELETE"],
    },
  });

  io.use((socket, next) => {
    const token =
      socket.handshake.auth?.token ||
      socket.handshake.headers?.authorization?.split(" ")[1];

    if (!token) {
      return next(new Error("Authentication token is required"));
    }

    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      socket.user = decoded;
      return next();
    } catch (error) {
      return next(new Error("Invalid or expired token"));
    }
  });

  io.on("connection", (socket) => {
    const userId = String(socket.user?.id || socket.user?._id || "");

    if (userId) {
      socket.join(`user:${userId}`);
    }

    socket.on("join_family", async ({ familyId }) => {
      try {
        if (!familyId) {
          return;
        }

        const family = await familyService.getFamilyById(familyId);
        if (family && familyService.isFamilyMember(family, userId)) {
          socket.join(`family:${familyId}`);
        } else {
          socket.emit("family_join_error", {
            status: "error",
            msg: "You are not a member of this family",
          });
        }
      } catch (error) {
        socket.emit("family_join_error", {
          status: "error",
          msg: error.message || "Failed to join family room",
        });
      }
    });

    socket.on("leave_family", ({ familyId }) => {
      if (familyId) {
        socket.leave(`family:${familyId}`);
      }
    });

    socket.on("private_message", async ({ recipientId, message, metadata = {} }) => {
      try {
        if (!recipientId || !message) {
          socket.emit("private_message_error", {
            status: "error",
            msg: "recipientId and message are required",
          });
          return;
        }

        const chat = await chatService.createPrivateMessage({
          senderId: userId,
          recipientId,
          message,
          metadata,
        });

        emitToUser(userId, "private_message", chat);
        emitToUser(recipientId, "private_message", chat);
      } catch (error) {
        socket.emit("private_message_error", {
          status: "error",
          msg: error.message || "Failed to send private message",
        });
      }
    });

    socket.on("family_message", async ({ familyId, message, metadata = {} }) => {
      try {
        if (!familyId || !message) {
          socket.emit("family_message_error", {
            status: "error",
            msg: "familyId and message are required",
          });
          return;
        }

        const family = await familyService.getFamilyById(familyId);
        if (!family || !familyService.isFamilyMember(family, userId)) {
          socket.emit("family_message_error", {
            status: "error",
            msg: "You are not a member of this family",
          });
          return;
        }

        const chat = await chatService.createFamilyMessage({
          senderId: userId,
          familyId,
          message,
          metadata,
        });

        emitToFamily(familyId, "family_message", chat);
      } catch (error) {
        socket.emit("family_message_error", {
          status: "error",
          msg: error.message || "Failed to send family message",
        });
      }
    });
  });

  return io;
};

const getIO = () => io;

const emitToUser = (userId, eventName, payload) => {
  if (io) {
    io.to(`user:${userId}`).emit(eventName, payload);
  }
};

const emitToFamily = (familyId, eventName, payload) => {
  if (io) {
    io.to(`family:${familyId}`).emit(eventName, payload);
  }
};

module.exports = {
  setSocketIO,
  getIO,
  emitToUser,
  emitToFamily,
};
