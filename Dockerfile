FROM node:20-bookworm-slim AS prod-deps
COPY /app /app
WORKDIR /app
RUN npm ci

FROM prod-deps AS builder

COPY --from=prod-deps /app/node_modules /app/node_modules
RUN rm -rf "app/(sample)"
RUN npm run build

FROM prod-deps AS runner

COPY --chown=node:node --from=prod-deps /app/node_modules /app/node_modules
COPY --chown=node:node  --from=builder /app/.next ./.next
COPY --chown=node:node  --from=builder /app/public ./public
COPY --chown=node:node --from=builder /app/package.json ./

USER node

EXPOSE 3000
CMD ["npm", "run", "start"]
