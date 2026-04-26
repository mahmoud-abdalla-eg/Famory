Base URL

http://localhost:5000

Existing routes

POST /api/V1/admin

POST /api/V1/admin/login

GET /api/V1/admin

PUT /api/V1/admin/:id

DELETE /api/V1/admin/:id

PATCH /api/V1/admin/:id

POST /api/V1/user

POST /api/V1/user/login

GET /api/V1/user

GET /api/V1/user/:id

PUT /api/V1/user/:id

DELETE /api/V1/user/:id

PATCH /api/V1/user/:id

GET /api/V1/user/confirm/:id

Family

POST /api/family
POST /api/family/join
GET /api/family/:familyId
Chat

POST /api/chats/private
POST /api/chats/family
GET /api/chats/history/private/:otherUserId
GET /api/chats/history/family/:familyId
Tasks

POST /api/tasks
GET /api/tasks/:familyId
PATCH /api/tasks/:taskId
DELETE /api/tasks/:taskId
Events

POST /api/events
GET /api/events/:familyId
Socket.IO events

join_family
leave_family
private_message
family_message
task_added
task_updated
task_removed
event_added
Auth header

Authorization: Bearer <JWT_TOKEN>


