Require Import
  Relation_Definitions Morphisms Setoid Program
  abstract_algebra theory.categories interfaces.functors.

Section contents.

  Context `{c: @Category Object A Aeq Aid Acomp}.

  Instance flipA: Arrows Object := flip A.

  Global Instance: @CatId Object flipA := Aid.
  Global Instance: @CatComp Object flipA := λ _ _ _, flip (Acomp _ _ _).
  Global Instance e: ∀ x y, Equiv (flipA x y) := λ x y, Aeq y x. 

  Global Instance: ∀ (x y: Object), Equivalence (e x y).
  Proof. intros. change (Equivalence ((=): Equiv (A y x))). apply _. Qed.

  Global Instance: ∀ (x y: Object), Setoid (x ⟶ y) := {}.

  Instance: ∀ (x y z: Object), Proper ((=) ==> (=) ==> (=)) (@comp Object flipA _ x y z).
  Proof.
   intros x y z ? ? E ? ? F.
   change (comp (H:=A) _ _ _ x1 x0 = comp (H:=A) _ _ _ y1 y0).
   now rewrite E, F.
  Qed.
  
  Global Instance cat: @Category Object flipA _ _ _.
  Proof with auto.
   destruct c.
   constructor; try apply _; auto.
     repeat intro. symmetry. apply comp_assoc.
    intros. apply id_r.
   intros. apply id_l.
  Qed.

End contents.

Section functors.

  (** Given a functor F: C → D, we have a functor F^op: C^op → D^op *)

  Context {C D} F `{Functor C (H:=Ce) D (H1:=De) F}.

  Definition fmap_op: @Fmap _ flipA _ flipA F := fun v w => @fmap _ _ _ _ F _ w v.

  Global Instance: Functor F fmap_op.
  Proof with intuition.
    unfold e, fmap_op, flipA, flip, CatId_instance_0, CatComp_instance_0, flip.
    pose proof (functor_from F).
    pose proof (functor_to F).
    constructor; repeat intro.
        apply cat.
       apply cat.
      destruct (functor_morphism F b a).
      constructor...
     set (preserves_id F a)...
    apply (@preserves_comp _ _ Ce _ _ _ _ De _ _ F)...
  Qed.

End functors.
