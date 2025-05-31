FROM node:22-alpine AS builder #builder is first stage
#update pckage manager + install shared libs
RUN apk update
RUN apk add --no-cache libc6-compat
# set working directory + copy files
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# 2nd stage
FROM node:22-alpine AS installer
RUN apk update
RUN apk add --no-cache libc6-compat
RUN apk add --no-cache openssl #needs orm forexmaple
WORKDIR /app
# copy files from builder stage
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/package-lock.json ./package-lock.json
COPY --from=builder /app/prisma ./prisma 
COPY --from=builder /app/dist ./dist

# clean install takes lock, remove modules if exists, no dev dependencies
RUN npm ci --omit=dev
# RUN npm run prisma:generate  


#3rd stage
FROM node:22-alpine AS runner
RUN apk add --no-cache libc6-compat
RUN apk add --no-cache openssl
WORKDIR /app
# dont run prod as root, create non root user
RUN addgroup --system --gid 1001 expressjs
RUN adduser --system --uid 1001 expressjs
USER expressjs
# copy from installer stage
COPY --from=installer /app .

# start the script in package.json
CMD ["npm", "run", "docker-start"]