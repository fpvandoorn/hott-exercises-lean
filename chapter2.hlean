import init.default types.pi types.sum types.arrow function_lemmas
open eq

section ex1
  variables {A : Type} {x y z : A} (p : x = y) (q : y = z)

  definition concat₁ : x = z := eq.rec' (λ a q, eq.rec' refl q) p q

  definition concat₂ : x = z := eq.rec' (λ a q, q) p q

  definition concat₃ : x = z := eq.rec' (λ a p, p) q p

  notation x `·₁` y := concat₁ x y
  notation x `·₂` y := concat₂ x y
  notation x `·₃` y := concat₃ x y

  definition coh₁ : (p ·₁ q) = (p ·₂ q) := by induction p; induction q; reflexivity

  definition coh₂ : (p ·₂ q) = (p ·₃ q) := by induction p; induction q; reflexivity

  definition coh₃ : (p ·₃ q) = (p ·₁ q) := by induction p; induction q; reflexivity
end ex1

section ex2
  variables {A : Type} {x y z : A} (p : x = y) (q : y = z)

  theorem triangle : (coh₁ p q) ⬝ (coh₂ p q) = (coh₃ p q)⁻¹ :=
  by induction p; induction q; reflexivity
end ex2

section ex3
  variables {A : Type} {x y z : A} (p : x = y) (q : y = z)

  definition concat₄ : x = z :=
  eq.rec' (λ a z, id) p z q

  notation x `·₄` y := concat₄ x y

  theorem coh₄₁ : (p ·₄ q) = (p ·₁ q) := by induction p; induction q; reflexivity

  theorem coh₄₂ : (p ·₄ q) = (p ·₂ q) := (coh₄₁ p q) ⬝ (coh₁ p q)

  theorem coh₄₃ : (p ·₄ q) = (p ·₃ q) := (coh₄₁ p q) ⬝ (coh₃ p q)⁻¹
end ex3

section ex5
  variables {A B : Type} {x y : A} (f : A → B) (p : x = y)

  definition precomp_tr_constant (q : f x = f y) : (p ▸ f x) = (f y) :=
  tr_constant p (f x) ⬝ q

  definition precomp_tr_constant_inv (q : p ▸ f x = f y) : f x = f y :=
  (tr_constant p (f x))⁻¹ ⬝ q

  definition is_equiv_precomp_tr_constant :=
  is_equiv.adjointify (precomp_tr_constant f p) (precomp_tr_constant_inv f p)
  (take q : p ▸ f x = f y,
    calc
      (precomp_tr_constant f p (precomp_tr_constant_inv f p q))
          = tr_constant p (f x) ⬝ ((tr_constant p (f x))⁻¹ ⬝ q)  : rfl
      ... = (tr_constant p (f x) ⬝ (tr_constant p (f x))⁻¹) ⬝ q  : !con.assoc'
      ... = idp ⬝ q                                             : !con.right_inv
      ... = q                                                   : idp_con)

  (take q : f x = f y,
    calc
      (precomp_tr_constant_inv f p (precomp_tr_constant f p q))
           = (tr_constant p (f x))⁻¹ ⬝ (tr_constant p (f x) ⬝ q) : rfl
       ... = ((tr_constant p (f x))⁻¹ ⬝ tr_constant p (f x)) ⬝ q : !con.assoc'
       ... = idp ⬝ q                                            : !con.left_inv
       ... = q                                                  : idp_con)
end ex5

section ex6
  variables {A : Type} {x y z : A} (p : x = y)

  definition is_equiv_precomp_p :=
  is_equiv.adjointify (λ q : y = z, p ⬝ q) (λ r : x = z, p⁻¹ ⬝ r)
  (by intro r; rewrite con_inv_cancel_left)
  (by intro q; rewrite inv_con_cancel_left)
end ex6

section ex7
  open sigma sigma.ops function pi
  variables {X X' : Type} {P : X → Type} {P' : X' → Type}
  variables (g : X → X') (h : Π (x : X), (P x) → P' (g x))


  definition componentwise_map (p : Σ (x : X), P x) : Σ (x : X'), P' x :=
  ⟨g (pr₁ p), h (pr₁ p) (pr₂ p)⟩

  variables {x y : Σ (x : X), P x} (p : pr₁ x = pr₁ y) (q : (pr₂ x) =[p] pr₂ y)

  definition pr₂_ap_componentwise_map : h (pr₁ x) (pr₂ x) =[ap g p] h (pr₁ y) (pr₂ y) :=
  have r₁ :  (p ▸ h (pr₁ x)) (pr₂ y) = h (pr₁ y) (pr₂ y),
  from homotopy_of_eq (apd h p) (pr₂ y),
  have r₂ : (p ▸ h (pr₁ x)) (pr₂ y) = (ap g p) ▸ h (pr₁ x) (pr₂ x), from
    calc
      transport (λ x, P(x) → P'(g x)) p (h (pr₁ x)) (pr₂ y)
           = transport (P' ∘ g) p
               (h (pr₁ x) (transport P (p⁻¹) (pr₂ y)))  : arrow_transport p (h (pr₁ x)) (pr₂ y)
       ... = transport (P' ∘ g) p (h (pr₁ x) (pr₂ x))   : ap _ (eq_tr_of_pathover q)⁻¹
       ... = (ap g p) ▸ (h (pr₁ x) (pr₂ x))             : tr_compose P' g p,
  pathover_of_tr_eq (r₂⁻¹ ⬝ r₁)

  definition ap_componentwise_map :   ap (componentwise_map g h) (sigma_eq p q)
                                    = sigma_eq (ap g p) (pr₂_ap_componentwise_map g h p q) :=
  begin
    induction x, induction y,
    esimp [pr₁, pr₂],
    cases q,
    reflexivity
  end
end ex7

section ex8
  open sum function
  variables {A A' B B' : Type} (g : A → A') (h : B → B')

  definition partwise_map : (A + B) → (A' + B')
  | partwise_map (inl a) := inl (g a)
  | partwise_map (inr b) := inr (h b)


  definition ap_partwise_map : Π {x y : A + B} (p : x = y),
                                 (partwise_map g h x) = (partwise_map g h y)
  | @ap_partwise_map (inl a) (inl a') p := ap (inl ∘ g) (lift.down (sum.encode p))
  | @ap_partwise_map (inr b) (inr b') p := ap (inr ∘ h) (lift.down (sum.encode p))
  | @ap_partwise_map (inl a) (inr b) p := empty.cases_on _ (lift.down (sum.encode p))
  | @ap_partwise_map (inr a) (inl b) p := empty.cases_on _ (lift.down (sum.encode p))

  definition ap_partwise_map_eq_ap {x y : A + B} (p : x = y)
                                   : ap (partwise_map g h) p = ap_partwise_map g h p :=
  begin
    induction p,
    cases x,
    all_goals reflexivity
  end
end ex8

section ex9
  open function prod prod.ops sum

  section non_dep
    variables {A B X : Type}

    definition is_equiv_sum_rec_unc : is_equiv (uncurry sum.rec) :=
    is_equiv.adjointify (uncurry sum.rec : (A → X) × (B → X) → (A + B → X))
                        (λ g : A + B → X, (g ∘ inl, g ∘ inr))
                        (take g : A + B → X,
                          show (uncurry sum.rec) (g ∘ inl, g ∘ inr) = g,
                          begin
                            eapply eq_of_homotopy,
                            intro x, induction x,
                            all_goals reflexivity,
                          end)
                        (take h : (A → X) × (B → X),
                          show ((uncurry sum.rec h) ∘ inl, (uncurry sum.rec h) ∘ inr) = h, from
                          match h with
                          | (h₁, h₂) := rfl
                          end)
  end non_dep

  section dep
    variables {A B : Type} {C : A + B → Type}

    definition is_equiv_sum_rec_unc' :
    is_equiv (uncurry sum.rec : (Π a, C (inl a)) × (Π b, C (inr b)) → Πx, C x) :=
      is_equiv.adjointify (uncurry sum.rec)
                          (λ g : Πx, C x, (g ∘₁ inl, g ∘₁ inr))
                          (take g : Πx, C x,
                            show (uncurry sum.rec) (g ∘₁ inl, g ∘₁ inr) = g,
                            begin
                              eapply eq_of_homotopy,
                              intro x, induction x,
                              all_goals reflexivity,
                            end)
                          (take h : (Πa, C (inl a)) × (Πb, C (inr b)),
                            show ((uncurry sum.rec h) ∘₁ inl, (uncurry sum.rec h) ∘₁ inr) = h, from
                            match h with
                            | (h₁, h₂) := rfl
                            end)
  end dep
end ex9

section ex10
  open sigma sigma.ops
  variables {A : Type} {B : A → Type} {C : (Σ (a : A), B a) → Type}

  definition rearrange : (Σ (x : A) (y : B x), C ⟨x, y⟩) → (Σ (p : Σ (x : A), B x), C p)
  | rearrange ⟨x, ⟨y, c⟩⟩ := ⟨⟨x, y⟩, c⟩

  definition is_equiv_rearrange : is_equiv (rearrange : (Σx y, C ⟨x, y⟩) → sigma C) :=
    is_equiv.adjointify rearrange
                        (λ t, match t with ⟨⟨x, y⟩, c⟩ := ⟨x, ⟨y, c⟩⟩ end)
                        (by intro p; cases p with [p₁, p₂]; cases p₁; reflexivity)
                        (by intro t; cases t with [t₁, t₂]; cases t₂; reflexivity)
end ex10
