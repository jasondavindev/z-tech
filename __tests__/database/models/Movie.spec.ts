import buildMovie from 'test/factories/Movie';
import Validation from 'test/helpers/Validation';

import { Movie } from '@models/index';

describe('models/Movie', () => {
  describe('when release date is null', () => {
    it('return an error', () => {
      const movie = buildMovie({ releaseDate: null } as Movie);
      expect(Validation(movie)).toEqual({
        releaseDate: {
          isDate: 'releaseDate must be a Date instance'
        }
      });
    });
  });
});
