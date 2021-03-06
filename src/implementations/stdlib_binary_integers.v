Require 
  interfaces.naturals theory.naturals peano_naturals theory.integers.
Require Import
  BinInt Morphisms Ring Program Arith NArith ZBinary
  abstract_algebra interfaces.integers
  natpair_integers stdlib_binary_naturals
  interfaces.additional_operations interfaces.orders
  nonneg_integers_naturals.

(* canonical names: *)
Instance Z_equiv: Equiv Z := eq.
Instance Z_plus: RingPlus Z := Zplus.
Instance Z_0: RingZero Z := 0%Z.
Instance Z_1: RingOne Z := 1%Z.
Instance Z_mult: RingMult Z := Zmult.
Instance Z_opp: GroupInv Z := Zopp.
  (* some day we'd like to do this with [Existing Instance] *)

Instance: Ring Z.
Proof.
  repeat (split; try apply _); repeat intro.
            now apply Zplus_assoc.
           now apply Zplus_0_r.
          now apply Zplus_opp_l.
         now apply Zplus_opp_r.
        now apply Zplus_comm.
       now apply Zmult_assoc.
      now apply Zmult_1_l.
     now apply Zmult_1_r.
    now apply Zmult_comm.
   now apply Zmult_plus_distr_r.
  now apply Zmult_plus_distr_l.
Qed.

(* misc: *)
Instance: ∀ x y : Z, Decision (x = y) := ZArith_dec.Z_eq_dec.

Add Ring Z: (rings.stdlib_ring_theory Z).

(* * Embedding N into Z *)
Instance inject_N_Z: Coerce BinNat.N Z := Z_of_N.

Instance: SemiRing_Morphism Z_of_N.
Proof.
  repeat (split; try apply _).
   exact Znat.Z_of_N_plus.
  exact Znat.Z_of_N_mult.
Qed.

Instance: Injective Z_of_N.
Proof.
  repeat (split; try apply _).
  intros x y E. now apply Znat.Z_of_N_eq_iff.
Qed.

(* SRpair N and Z are isomorphic *)
Definition Npair_to_Z (x : SRpair N) : Z := 'pos x - 'neg x.

Instance: Proper (=) Npair_to_Z.
Proof.
  intros x y E. do 2 red in E. unfold Npair_to_Z.
  apply (right_cancellation (+) ('neg y + 'neg x)). ring_simplify.
  now rewrite <-?rings.preserves_plus, E, commutativity.
Qed.

Instance: SemiRing_Morphism Npair_to_Z.
Proof.
  repeat (split; try apply _).
   intros [xp xn] [yp yn].
   change ('(xp + yp) - '(xn + yn) = 'xp - 'xn + ('yp - 'yn)).
   rewrite ?rings.preserves_plus. ring.
  intros [xp xn] [yp yn].
  change ('(xp * yp + xn * yn) - '(xp * yn + xn * yp) = ('xp - 'xn) * ('yp - 'yn)).
  rewrite ?rings.preserves_plus, ?rings.preserves_mult. ring.
Qed.

Instance: Injective Npair_to_Z.
Proof. 
  split; try apply _.
  intros [xp xn] [yp yn] E.
  unfold Npair_to_Z in E. do 2 red. simpl in *.
  apply (injective (coerce N Z)).
  rewrite ?rings.preserves_plus.
  apply (right_cancellation (+) ('xp - 'xn)). rewrite E at 1. ring.
Qed.

Instance Z_to_Npair: Inverse Npair_to_Z := λ x,
  match x with
  | Z0 => C 0 0
  | Zpos p => C (Npos p) 0
  | Zneg p => C 0 (Npos p)
  end.

Instance: Surjective Npair_to_Z.
Proof.
  split; try apply _.
  intros x y E. compute in E. rewrite E. (* FIXME: loop without the compute *)  
  now destruct y as [|p|p].
Qed.

Instance: Bijective Npair_to_Z := {}.

Instance: SemiRing_Morphism Z_to_Npair.
Proof. change (SemiRing_Morphism (Npair_to_Z⁻¹)). split; apply _. Qed.

Instance: IntegersToRing Z := integers.retract_is_int_to_ring Npair_to_Z.
Instance: Integers Z := integers.retract_is_int Npair_to_Z.

Instance Z_le: Le Z := Zle.
Instance Z_lt: Lt Z := Zlt.

Instance: SemiRingOrder Z_le.
Proof.
  assert (PartialOrder Z_le).
   repeat (split; try apply _).
   exact Zorder.Zle_antisym.
  rapply rings.from_ring_order.
   repeat (split; try apply _).
   intros x y E. now apply Zorder.Zplus_le_compat_l.
  intros x E y F. now apply Zorder.Zmult_le_0_compat.
Qed.

Instance: TotalRelation Z_le.
Proof. 
  intros x y.
  destruct (Zorder.Zle_or_lt x y); intuition.
  right. now apply Zorder.Zlt_le_weak.
Qed.

Instance: FullPseudoSemiRingOrder Z_le Z_lt.
Proof.
  rapply semirings.dec_full_pseudo_srorder.
  split.
   intro. split. now apply Zorder.Zlt_le_weak. now apply Zorder.Zlt_not_eq.
  intros [E1 E2]. destruct (Zorder.Zle_lt_or_eq _ _ E1). easy. now destruct E2.
Qed.

(* * Embedding of the Peano naturals into [Z] *)
Instance inject_nat_Z: Coerce nat Z := Z_of_nat.

Instance: SemiRing_Morphism Z_of_nat.
Proof.
  repeat (split; try apply _).
   exact Znat.inj_plus.
  exact Znat.inj_mult.
Qed.

(* absolute value *)
Program Instance: IntAbs Z nat := Zabs_nat.
Next Obligation.
  rewrite <-(naturals.to_semiring_unique Z_of_nat).
  rewrite Zabs.inj_Zabs_nat.
  destruct (total (≤) 0 x).
   left. 
   now apply Z.abs_eq.
  right.
  rewrite Z.abs_neq by easy. now apply rings.opp_involutive.
Qed.

Program Instance: IntAbs Z N := Zabs_N.
Next Obligation.
  rewrite <-(naturals.to_semiring_unique Z_of_N).
  rewrite Znat.Z_of_N_abs.
  destruct (total (≤) 0 x).
   left. 
   now apply Z.abs_eq.
  right.
  rewrite Z.abs_neq by easy. now apply rings.opp_involutive.
Qed.

(* Efficient nat_pow *)
Program Instance Z_pow: Pow Z (Z⁺) := Z.pow.

Instance: NatPowSpec Z (Z⁺) Z_pow.
Proof.
  split; unfold pow, Z_pow.
    intros x1 y1 E1 [x2 Ex2] [y2 Ey2] E2.
    unfold equiv, sig_equiv in E2.
    simpl in *. now rewrite E1, E2.
   intros. now apply Z.pow_0_r.
  intros x n.
  rewrite rings.preserves_plus, rings.preserves_1.  
  rewrite <-(Z.pow_1_r x) at 2. apply Z.pow_add_r.
   auto with zarith.
  now destruct n.
Qed.

Instance Z_Npow: Pow Z N := λ x n, Z.pow x ('n).

Instance: NatPowSpec Z N Z_Npow.
Proof.
  split; unfold pow, Z_Npow.
    solve_proper.
   intros. now apply Z.pow_0_r.
  intros x n.
  rewrite rings.preserves_plus, rings.preserves_1.
  rewrite <-(Z.pow_1_r x) at 2. apply Z.pow_add_r.
   auto with zarith.
  now destruct n.
Qed.

(* Efficient shiftl *)
Program Instance Z_shiftl: ShiftL Z (Z⁺) := Z.shiftl.

Instance: ShiftLSpec Z (Z⁺) Z_shiftl.
Proof.
  apply shiftl_spec_from_nat_pow.
  intros x [n En].
  apply Z.shiftl_mul_pow2.
  now apply En.
Qed.

Instance Z_Nshiftl: ShiftL Z N := λ x n, Z.shiftl x ('n).

Instance: ShiftLSpec Z N Z_Nshiftl.
Proof.
  apply shiftl_spec_from_nat_pow.
  intros x n.
  apply Z.shiftl_mul_pow2.
  now destruct n.
Qed.

Program Instance: Abs Z := Zabs.
Next Obligation.
  split; intros E.
   now apply Z.abs_eq.
  now apply Z.abs_neq.
Qed.
