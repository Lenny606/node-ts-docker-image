import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Handle connection errors
prisma.$on('query', (e) => {
  console.log('Query: ' + e.query);
  console.log('Duration: ' + e.duration + 'ms');
});

export default prisma; 