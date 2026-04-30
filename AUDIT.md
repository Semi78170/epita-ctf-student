# 1. Contexte
L’objectif est d’analyser et d’exploiter un contrat intelligent déployé sur le réseau Sepolia. Le scénario impose la réalisation d’une attaque permettant d’extraire des fonds depuis un contrat cible, puis de les redistribuer automatiquement selon un schéma imposé, le tout dans une seule transaction atomique.
Le travail demandé ne se limite pas à la réussite de l’attaque, mais inclut également une analyse complète de la cible, la formulation d’hypothèses, la mise en place d’une stratégie, ainsi que la documentation détaillée de toutes les étapes, y compris en cas d’échec.

# 2. Analyse du contrat
Le contrat cible analysé est déployé à l’adresse :

0xed5415679D46415f6f9a82677F8F4E9ed9D1302b

L’analyse du contrat permet d’identifier plusieurs éléments importants :

Des fonctions publiques permettant d’interagir avec le contrat.
Une logique de type “jeu” ou “casino”, où l’utilisateur doit fournir certaines valeurs pour tenter de gagner.
Le succès de l’interaction dépend de plusieurs paramètres, notamment une valeur de prédiction et un identifiant de round.

Le fonctionnement général repose sur la validation de conditions spécifiques. Si celles-ci sont respectées, le contrat envoie des fonds à l’utilisateur.
L’analyse met en évidence plusieurs points sensibles :

Le résultat dépend d’un calcul interne, potentiellement basé sur des données accessibles.
Certaines variables influencent directement le résultat, comme :
une valeur de prédiction (_guess)
un identifiant de round (_round)
un paramètre de validation (_nonce)

Le contrat semble également dépendre de sources externes ou semi-prévisibles :

block.timestamp (temps du bloc)
blockhash (hash du bloc)
un oracle externe (prix BTC/USD)

Ces éléments peuvent, dans certains cas, être partiellement prévisibles ou manipulables, ce qui représente un point d’intérêt pour une attaque.

L’implémentation repose sur le contrat Drainer.sol, fourni dans le dépôt.
Lors de la phase de configuration, un problème de compilation a été rencontré en raison de la directive suivante :
- pragma solidity =0.8.34;
Cette version spécifique n’étant pas disponible dans mon environnement local, une modification a été nécessaire. La directive a été adaptée comme suit :
- pragma solidity ^0.8.19;
Ce changement a permis de rendre le projet compatible avec les versions de compilateur disponibles tout en conservant un comportement équivalent pour les besoins du challenge.

# 3. Hypothèses
Suite à l’analyse, plusieurs hypothèses peuvent être formulées :

Il est potentiellement possible de prédire le résultat si celui-ci dépend de données publiques (blockchain ou oracle).
Certaines valeurs internes peuvent être reconstruites via l’analyse du storage.
Une attaque basée sur le timing pourrait être envisageable si le contrat dépend de block.timestamp.
La validation via un _nonce pourrait être contournée ou satisfaite par une recherche (brute force).

Cependant, même si ces hypothèses sont valides en théorie, leur exploitation reste complexe en pratique en raison de la concurrence sur le réseau et de la variabilité de l’état du contrat.

# 4. Stratégie
Deux approches étaient possibles :

Option A : Script direct
Interaction simple avec le contrat cible.
Plus rapide à tester, mais ne permet pas de garantir l’atomicité.
Option B : Contrat Drainer
Implémentation d’un contrat intermédiaire respectant l’interface imposée.
Permet de réaliser l’attaque et la distribution des fonds dans une seule transaction.

👉 Le choix s’est porté sur l’option B (contrat Drainer).

Ce choix est justifié par les contraintes du sujet, qui imposent une exécution atomique (attaque + distribution). L’utilisation d’un contrat permet de mieux contrôler le déroulement des opérations et de respecter cette exigence.

# 5. Implémentation
L’implémentation du contrat Drainer a été réalisée en respectant l’interface imposée.

La fonction `attack()` sert de point d’entrée principal. Dans cette version, elle contient une structure simplifiée permettant d’enchaîner directement avec la fonction `distribute()` afin de respecter la contrainte d’atomicité.

La fonction `distribute()` permet de répartir automatiquement le solde du contrat selon le schéma imposé :
- 50% pour le lieutenant 1
- 30% pour le lieutenant 2
- 20% pour le lieutenant 3

L’attaque elle-même n’a pas été complètement implémentée, mais la structure du contrat permettrait d’intégrer une logique d’exploitation dans la fonction `attack()`.

# 6. Tests
Un premier test a consisté à envoyer des fonds au contrat afin de vérifier sa capacité à recevoir de l’ETH.
Un appel à la fonction attack() a été effectué avec des paramètres arbitraires.

La transaction a échoué avec l’erreur suivante :
"FairCasino: invalid payload signature"

Cela indique que le contrat cible vérifie une signature ou un payload spécifique avant d’autoriser l’exécution.

Cette vérification empêche les appels naïfs et implique que les paramètres doivent être calculés avec précision à partir de données internes ou externes.

Cette observation confirme que l’attaque nécessite une compréhension approfondie du mécanisme de validation du contrat cible.

# 7. Problèmes rencontrés
Plusieurs difficultés techniques ont été rencontrées au cours du projet :

- Un problème de compilation initial lié à la version du compilateur Solidity. La version spécifiée (0.8.34) n’étant pas disponible, une adaptation vers la version 0.8.19 a été nécessaire.

- Des erreurs lors du déploiement, notamment l’oubli du flag `--broadcast`, ce qui entraînait une simulation sans envoi réel de la transaction.

- Un manque de fonds sur le réseau Sepolia, empêchant l’exécution des transactions. Ce problème a été résolu en obtenant des ETH de test via l’enseignant.

- Des erreurs lors des interactions avec le contrat, notamment :
  - "invalid payload signature", indiquant une mauvaise construction des paramètres.
  - difficulté à estimer le gas lors de certaines transactions.

- Une tentative de vérification du contrat sur l’explorateur de blocs (:contentReference[oaicite:0]{index=0}) qui a échoué en raison d’une non-correspondance du bytecode. Cela est dû à des modifications du code après le déploiement.

Ces problèmes ont permis de mieux comprendre les contraintes liées au développement et au déploiement de smart contracts.

# 8. Analyse d’échec
L’attaque n’a pas pu être menée à bien.

Les tests ont montré que le contrat cible applique une validation stricte des paramètres via une "payload signature". Toute tentative avec des valeurs arbitraires est rejetée.

Cela indique que :
- les paramètres (_guess, _round, _nonce) doivent être calculés précisément
- une logique interne (probablement un hash ou une signature) est utilisée pour vérifier la validité de l’appel

Sans accès exact à cette logique ou sans reconstruction du mécanisme de génération, il est impossible de produire une interaction valide.

De plus, l’utilisation d’un oracle externe et de données liées à la blockchain (timestamp, blockhash) complexifie encore davantage la prédiction.

Enfin, la concurrence sur le réseau constitue un facteur aggravant, car d’autres acteurs peuvent interagir avec le contrat en parallèle.

Ainsi, même si la structure de l’attaque est correcte, l’absence de calcul exact des paramètres empêche son succès.

# 9. Conclusion
Ce projet a permis de mettre en pratique l’analyse et l’interaction avec des smart contracts sur un réseau blockchain.

Même si l’attaque n’a pas abouti, plusieurs compétences importantes ont été développées :
- compréhension du fonctionnement d’un contrat complexe
- analyse des mécanismes de validation
- déploiement et interaction avec un contrat sur Sepolia
- gestion des erreurs et des contraintes techniques

L’approche choisie, basée sur un contrat Drainer, respecte les contraintes d’atomicité imposées par le sujet.

L’échec de l’attaque met en évidence la complexité des systèmes sécurisés reposant sur des signatures ou des mécanismes cryptographiques.

Ce travail montre qu’une attaque ne repose pas uniquement sur l’exécution, mais surtout sur la compréhension du système cible.
