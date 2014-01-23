node default {
  # Setup pre and post run stages
  stage { ['pre', 'post']: }
  Stage['pre'] -> Stage['main'] -> Stage['post']

  class { 'common': }
}
