import Ember from 'ember';

export function eq(args) {
  return args[0] === args[1];
}

export default Ember.Helper.helper(eq);