Require Import 
  Morphisms BigZ
  interfaces.abstract_algebra interfaces.integers 
  interfaces.additional_operations fast_naturals.
Require Export
  ZType_integers.

Module BigZ_Integers := ZType_Integers BigZ.

Instance inject_fastN_fastZ: Coerce bigN bigZ := BigZ.Pos.

Instance: SemiRing_Morphism inject_fastN_fastZ.
Proof. repeat (split; try apply _); intuition. Qed.

Program Instance bigZ_pow: Pow bigZ bigN := λ x n, BigZ.pow x ('n).

Instance: NatPowSpec bigZ bigN _.
Proof.
  split; unfold pow, bigZ_pow. 
    solve_proper.
   intro. apply BigZ.pow_0_r.
  intros x n.
  rewrite rings.preserves_plus, rings.preserves_1, BigZ.add_1_l.
  apply BigZ.pow_succ_r.
  change (0 ≤ coerce bigN bigZ n).
  now apply naturals.to_semiring_nonneg.
Qed.

Instance fastZ_shiftl: ShiftL bigZ bigN := λ x n, BigZ.shiftl x ('n).

Instance: ShiftLSpec bigZ bigN _.
Proof.
  apply shiftl_spec_from_nat_pow.
  intros. apply BigZ.shiftl_mul_pow2.
  change (0 ≤ coerce bigN bigZ n).
  now apply naturals.to_semiring_nonneg.
Qed.
