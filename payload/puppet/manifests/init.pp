node default {
  # Setup pre and post run stages
  stage { ['pre', 'post']: }
  Stage['pre'] -> Stage['main'] -> Stage['post']

  # Apply role from fact or hieradata
  if $::nepho_role == undef {
    notice('Applying default role')
    include ::role
  } else {
    notice("Applying role ${::nepho_role}")
    include "::role::${::nepho_role}"
  }
}
