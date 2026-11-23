/**
 * Prisma Database Seeder
 * Populates the database with sample data for testing
 */

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('Starting database seeding...');

  // Clear existing data (in reverse order due to foreign keys)
  console.log('Clearing existing data...');
  await prisma.bookCategory.deleteMany();
  await prisma.book.deleteMany();
  await prisma.author.deleteMany();
  await prisma.category.deleteMany();

  // Create Authors
  console.log('Creating authors...');
  const tolkien = await prisma.author.create({
    data: {
      name: 'J.R.R. Tolkien',
      country: 'England',
      birthYear: 1892,
    },
  });

  const orwell = await prisma.author.create({
    data: {
      name: 'George Orwell',
      country: 'England',
      birthYear: 1903,
    },
  });

  const austen = await prisma.author.create({
    data: {
      name: 'Jane Austen',
      country: 'England',
      birthYear: 1775,
    },
  });

  const hesse = await prisma.author.create({
    data: {
      name: 'Hermann Hesse',
      country: 'Germany',
      birthYear: 1877,
    },
  });

  console.log(`Created ${4} authors`);

  // Create Categories
  console.log('Creating categories...');
  const fantasy = await prisma.category.create({
    data: {
      name: 'Fantasy',
      description: 'Fantasy and fantastical literature',
    },
  });

  const classics = await prisma.category.create({
    data: {
      name: 'Classics',
      description: 'Literary classics',
    },
  });

  const sciFi = await prisma.category.create({
    data: {
      name: 'Science Fiction',
      description: 'Science fiction literature',
    },
  });

  const novel = await prisma.category.create({
    data: {
      name: 'Novel',
      description: 'Novels of various genres',
    },
  });

  const dystopia = await prisma.category.create({
    data: {
      name: 'Dystopia',
      description: 'Dystopian literature',
    },
  });

  console.log(`Created ${5} categories`);

  // Create Books with Categories
  console.log('Creating books...');

  const hobbit = await prisma.book.create({
    data: {
      title: 'The Hobbit',
      authorId: tolkien.id,
      isbn: '978-3-423-21212-0',
      publicationYear: 1937,
      pages: 336,
      categories: {
        create: [
          { categoryId: fantasy.id },
          { categoryId: classics.id },
        ],
      },
    },
  });

  const lotr = await prisma.book.create({
    data: {
      title: 'The Lord of the Rings',
      authorId: tolkien.id,
      isbn: '978-3-608-93830-2',
      publicationYear: 1954,
      pages: 1216,
      categories: {
        create: [
          { categoryId: fantasy.id },
          { categoryId: classics.id },
        ],
      },
    },
  });

  const nineteen84 = await prisma.book.create({
    data: {
      title: '1984',
      authorId: orwell.id,
      isbn: '978-3-548-23440-9',
      publicationYear: 1949,
      pages: 336,
      categories: {
        create: [
          { categoryId: sciFi.id },
          { categoryId: dystopia.id },
          { categoryId: classics.id },
        ],
      },
    },
  });

  const animalFarm = await prisma.book.create({
    data: {
      title: 'Animal Farm',
      authorId: orwell.id,
      isbn: '978-3-257-20057-7',
      publicationYear: 1945,
      pages: 144,
      categories: {
        create: [
          { categoryId: dystopia.id },
          { categoryId: classics.id },
        ],
      },
    },
  });

  const prideAndPrejudice = await prisma.book.create({
    data: {
      title: 'Pride and Prejudice',
      authorId: austen.id,
      isbn: '978-3-15-010926-0',
      publicationYear: 1813,
      pages: 432,
      categories: {
        create: [
          { categoryId: classics.id },
          { categoryId: novel.id },
        ],
      },
    },
  });

  const steppenwolf = await prisma.book.create({
    data: {
      title: 'Steppenwolf',
      authorId: hesse.id,
      isbn: '978-3-518-36675-9',
      publicationYear: 1927,
      pages: 288,
      categories: {
        create: [
          { categoryId: classics.id },
          { categoryId: novel.id },
        ],
      },
    },
  });

  console.log(`Created ${6} books with category associations`);

  console.log('\nSeeding completed successfully!');
  console.log('-----------------------------------');
  console.log(`Authors: ${4}`);
  console.log(`Categories: ${5}`);
  console.log(`Books: ${6}`);
  console.log('-----------------------------------');
}

main()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
