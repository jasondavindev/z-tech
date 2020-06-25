import { buildActor } from 'test/factories/Actor';
import { populateMovie, buildMovie } from 'test/factories/Movie';
import cleanTables from 'test/helpers/Database';
import Container from 'typedi';
import { Connection } from 'typeorm';

import TypeORMLoader from '@/loaders/Typeorm';
import CensorshipLevel from '@/types/CensorshipLevel';
import { Movie } from '@models/index';
import MovieService from '@services/Movie';

describe('services/Movie', () => {
  let connection: Connection;
  let service: MovieService;

  beforeAll(async () => {
    connection = await TypeORMLoader();
    service = Container.get(MovieService);
  });

  afterAll(async () => {
    await cleanTables(connection, [Movie]);
    await connection.close();
  });

  describe('#create', () => {
    describe('when already exists a movie with same name', () => {
      it('throws an error', async () => {
        await populateMovie(1, { name: 'Test' } as Movie);

        const movie = buildMovie({ name: 'Test' } as Movie);
        expect(service.create(movie)).rejects.toThrowError();
      });
    });

    describe('when the movie is ok', () => {
      it('creates the movie', async () => {
        const actor = buildActor();
        const movie = buildMovie({ actors: [actor] } as Movie);
        expect(await service.create(movie)).toBeDefined();
      });
    });
  });

  describe('#find', () => {
    beforeEach(() => cleanTables(connection, [Movie]));

    describe('when is passed censorship level', () => {
      it('the results is filtered by censorship level', async () => {
        await populateMovie(4, {
          censorshipLevel: CensorshipLevel.Censored
        } as Movie);

        await populateMovie(4, { censorshipLevel: CensorshipLevel.NotCensore } as Movie);

        const result = await service.find({ censorshipLevel: CensorshipLevel.Censored });

        expect(result).toHaveLength(4);
      });
    });

    describe('when is not passed censorship level', () => {
      it('the results is not filtered', async () => {
        await populateMovie(4, {
          censorshipLevel: CensorshipLevel.Censored
        } as Movie);

        await populateMovie(4, { censorshipLevel: CensorshipLevel.NotCensore } as Movie);

        const result = await service.find();

        expect(result).toHaveLength(8);
      });
    });
  });
});
