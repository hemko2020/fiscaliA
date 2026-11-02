import * as admin from 'firebase-admin';
import { embed, embedMany } from '@genkit-ai/ai/embedder';
import { textMultilingualEmbedding002 } from '@genkit-ai/vertexai';
import { createHash } from 'node:crypto';
import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import {
  configurerGenkitVertexAi,
  obtenirConfigurationVertexAi,
} from '../configuration_vertex_ai';

type Section = {
  titre: string;
  niveau: number;
  contenu: string;
};

type DocumentManifeste = {
  id: string;
  slug: string;
  titre: string;
  chemin: string;
  sourceType: string;
  categorie: string;
  officiel?: boolean;
  autorite?: string;
  urlPrincipale?: string;
  modeAcces?: string;
  periodiciteMiseAJour?: string;
  priorite?: number;
  tags?: string[];
};

type ManifesteCorpus = {
  versionCorpus?: string;
  namespaceCorpus?: string;
  collectionFirestore?: string;
  description?: string;
  documents: DocumentManifeste[];
};

type DocumentSource = DocumentManifeste & {
  cheminAbsolu: string;
  cheminRelatif: string;
  officiel: boolean;
  autorite: string;
  modeAcces: string;
  periodiciteMiseAJour: string;
  priorite: number;
  tags: string[];
  collectionFirestore: string;
  namespaceCorpus: string;
  versionCorpus: string;
};

type Chunk = {
  id: string;
  titre: string;
  contenu: string;
  sectionTitre: string;
  sectionOrdre: number;
  chunkOrdre: number;
  documentSlug: string;
  sourceId: string;
  sourceNom: string;
  sourceType: string;
  sourceCategorie: string;
  sourceAutorite: string;
  sourceUrl: string;
  sourceModeAcces: string;
  sourcePeriodiciteMiseAJour: string;
  sourceOfficielle: boolean;
  sourcePriorite: number;
  tagsSource: string[];
  sourceDocument: string;
  sourcePath: string;
  corpusNamespace: string;
  corpusVersion: string;
};

type ChunkAvecEmbedding = Chunk & {
  embedding: number[];
};

const projectId =
  process.env.GCLOUD_PROJECT ??
  process.env.GCP_PROJECT ??
  process.env.GOOGLE_CLOUD_PROJECT ??
  'fiscalia-f1eaa';
const collectionParDefaut = 'lois_fiscales';
const namespaceCorpusParDefaut = 'rag_fiscal_fr_sources_officielles';
const versionCorpusParDefaut = '2026-05-01';
const vectorFieldName = 'embedding';
const racineProjet = path.resolve(__dirname, '../../..');
const repertoireDocumentation = path.join(racineProjet, 'documentations');
const nomGuideLegacy = 'Guide de Constitution du RAG : Sources Fiscales Françaises.md';
const cheminManifesteParDefaut = path.join(
  racineProjet,
  'assets/knowledge/manifestes/rag_corpus_manifest.json',
);
const embeddingModel = textMultilingualEmbedding002;
const embeddingDimensions = embeddingModel.info?.dimensions ?? 768;
const embeddingTaskDocument = 'RETRIEVAL_DOCUMENT' as const;
const embeddingTaskQuery = 'RETRIEVAL_QUERY' as const;

admin.initializeApp({ projectId });
const db = admin.firestore();
const configurationVertexAi = obtenirConfigurationVertexAi(projectId);

configurerGenkitVertexAi({
  enableTracingAndMetrics: false,
  logLevel: 'info',
  projectId,
});

function normaliserTexte(texte: string): string {
  return texte
    .replace(/\r\n/g, '\n')
    .replace(/\u00a0/g, ' ')
    .replace(/[ \t]+\n/g, '\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

function normaliserCleRecherche(texte: string): string {
  return texte
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/\s+/g, ' ')
    .trim()
    .toLowerCase();
}

function genererSlug(texte: string): string {
  return normaliserCleRecherche(texte)
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

async function fichierExiste(cheminFichier: string): Promise<boolean> {
  try {
    await fs.access(cheminFichier);
    return true;
  } catch {
    return false;
  }
}

function resoudreCheminDepuisManifeste(
  cheminDocument: string,
  cheminManifeste: string,
): string {
  if (path.isAbsolute(cheminDocument)) {
    return cheminDocument;
  }

  if (
    cheminDocument.startsWith('./') ||
    cheminDocument.startsWith('../')
  ) {
    return path.resolve(path.dirname(cheminManifeste), cheminDocument);
  }

  return path.resolve(racineProjet, cheminDocument);
}

function validerChaine(
  valeur: unknown,
  proprietes: string,
  contexte: string,
): string {
  if (typeof valeur !== 'string' || !valeur.trim()) {
    throw new Error(`Valeur invalide pour "${proprietes}" dans ${contexte}.`);
  }

  return valeur.trim();
}

function convertirTags(valeur: unknown): string[] {
  if (!Array.isArray(valeur)) {
    return [];
  }

  return valeur
    .map((item) => String(item).trim())
    .filter(Boolean);
}

async function chargerManifesteCorpus(
  cheminManifeste: string,
): Promise<DocumentSource[]> {
  const contenu = await fs.readFile(cheminManifeste, 'utf8');
  const manifeste = JSON.parse(contenu) as ManifesteCorpus;

  if (!Array.isArray(manifeste.documents) || manifeste.documents.length === 0) {
    throw new Error(
      `Le manifeste ${cheminManifeste} ne contient aucun document à ingérer.`,
    );
  }

  const collectionFirestore =
    manifeste.collectionFirestore?.trim() || collectionParDefaut;
  const namespaceCorpus =
    manifeste.namespaceCorpus?.trim() || namespaceCorpusParDefaut;
  const versionCorpus =
    manifeste.versionCorpus?.trim() || versionCorpusParDefaut;

  const documents = await Promise.all(
    manifeste.documents.map(async (document, index) => {
      const contexte = `document #${index + 1} du manifeste`;
      const id = validerChaine(document.id, 'id', contexte);
      const slug = validerChaine(document.slug, 'slug', contexte);
      const titre = validerChaine(document.titre, 'titre', contexte);
      const cheminRelatif = validerChaine(document.chemin, 'chemin', contexte);
      const sourceType = validerChaine(document.sourceType, 'sourceType', contexte);
      const categorie = validerChaine(document.categorie, 'categorie', contexte);
      const cheminAbsolu = resoudreCheminDepuisManifeste(
        cheminRelatif,
        cheminManifeste,
      );

      if (!(await fichierExiste(cheminAbsolu))) {
        throw new Error(
          `Document introuvable pour "${titre}": ${cheminAbsolu}.`,
        );
      }

      return {
        id,
        slug,
        titre,
        chemin: cheminRelatif,
        cheminAbsolu,
        cheminRelatif,
        sourceType,
        categorie,
        officiel: Boolean(document.officiel),
        autorite: document.autorite?.trim() || 'Source publique non précisée',
        urlPrincipale: document.urlPrincipale?.trim(),
        modeAcces: document.modeAcces?.trim() || 'Accès documentaire',
        periodiciteMiseAJour:
          document.periodiciteMiseAJour?.trim() || 'ponctuelle',
        priorite: document.priorite ?? Math.max(1, 100 - index),
        tags: convertirTags(document.tags),
        collectionFirestore,
        namespaceCorpus,
        versionCorpus,
      };
    }),
  );

  return documents;
}

async function resoudreGuideLegacy(): Promise<DocumentSource> {
  const fichiers = await fs.readdir(repertoireDocumentation);
  const cibleNormalisee = normaliserCleRecherche(nomGuideLegacy);
  const fichierTrouve = fichiers.find((fichier) => {
    const nomNormalise = normaliserCleRecherche(fichier);
    return (
      nomNormalise === cibleNormalisee ||
      (nomNormalise.includes('guide de constitution du rag') &&
        nomNormalise.includes('sources fiscales francaises') &&
        nomNormalise.endsWith('.md'))
    );
  });

  if (!fichierTrouve) {
    throw new Error(
      `Impossible de trouver le guide source dans ${repertoireDocumentation}.`,
    );
  }

  return {
    id: 'guide-rag-sources-fiscales-francaises',
    slug: 'guide-rag-sources-fiscales-francaises',
    titre: 'Guide de Constitution du RAG : Sources Fiscales Françaises',
    chemin: path.join('documentations', fichierTrouve),
    cheminAbsolu: path.join(repertoireDocumentation, fichierTrouve),
    cheminRelatif: path.join('documentations', fichierTrouve),
    sourceType: 'guide_rag',
    categorie: 'architecture_rag',
    officiel: false,
    autorite: 'FiscalIA',
    urlPrincipale: undefined,
    modeAcces: 'Documentation interne',
    periodiciteMiseAJour: 'ponctuelle',
    priorite: 10,
    tags: ['rag', 'architecture', 'sources fiscales'],
    collectionFirestore: collectionParDefaut,
    namespaceCorpus: namespaceCorpusParDefaut,
    versionCorpus: versionCorpusParDefaut,
  };
}

async function resoudreDocumentsSource(): Promise<DocumentSource[]> {
  const argument = process.argv[2];

  if (argument) {
    const cheminArgument = path.resolve(argument);
    if (path.extname(cheminArgument).toLowerCase() === '.json') {
      return chargerManifesteCorpus(cheminArgument);
    }

    if (!(await fichierExiste(cheminArgument))) {
      throw new Error(`Document source introuvable: ${cheminArgument}`);
    }

    const nomFichier = path.basename(cheminArgument);
    const slug = genererSlug(path.parse(nomFichier).name);
    return [
      {
        id: slug,
        slug,
        titre: path.parse(nomFichier).name,
        chemin: path.relative(racineProjet, cheminArgument),
        cheminAbsolu: cheminArgument,
        cheminRelatif: path.relative(racineProjet, cheminArgument),
        sourceType: 'document_libre',
        categorie: 'document_reference',
        officiel: false,
        autorite: 'FiscalIA',
        urlPrincipale: undefined,
        modeAcces: 'Import manuel',
        periodiciteMiseAJour: 'manuelle',
        priorite: 50,
        tags: ['rag', 'import manuel'],
        collectionFirestore: collectionParDefaut,
        namespaceCorpus: namespaceCorpusParDefaut,
        versionCorpus: versionCorpusParDefaut,
      },
    ];
  }

  if (await fichierExiste(cheminManifesteParDefaut)) {
    return chargerManifesteCorpus(cheminManifesteParDefaut);
  }

  return [await resoudreGuideLegacy()];
}

function extraireSections(markdown: string): Section[] {
  const lignes = normaliserTexte(markdown).split('\n');
  const sections: Section[] = [];
  let titreCourant = 'Introduction';
  let niveauCourant = 1;
  let buffer: string[] = [];

  const pousserSection = () => {
    const contenu = normaliserTexte(buffer.join('\n'));
    if (!contenu) return;
    sections.push({
      titre: titreCourant,
      niveau: niveauCourant,
      contenu,
    });
  };

  for (const ligne of lignes) {
    const match = ligne.match(/^(#{1,3})\s+(.*)$/);
    if (match) {
      pousserSection();
      titreCourant = match[2].trim();
      niveauCourant = match[1].length;
      buffer = [];
      continue;
    }
    buffer.push(ligne);
  }

  pousserSection();
  return sections;
}

function construirePrefixeChunk(
  document: DocumentSource,
  section: Section,
): string {
  const lignes = [
    `Source: ${document.titre}`,
    `Source officielle: ${document.officiel ? 'oui' : 'non'}`,
    `Autorité: ${document.autorite}`,
    `Catégorie: ${document.categorie}`,
    document.urlPrincipale ? `URL officielle: ${document.urlPrincipale}` : null,
    `Mode d'accès: ${document.modeAcces}`,
    `Périodicité de mise à jour: ${document.periodiciteMiseAJour}`,
    document.tags.length > 0 ? `Tags: ${document.tags.join(', ')}` : null,
    `Section: ${section.titre}`,
  ].filter(Boolean);

  return lignes.join('\n');
}

function decouperSection(
  section: Section,
  sectionOrdre: number,
  document: DocumentSource,
): Chunk[] {
  const morceaux = section.contenu
    .split(/\n\n+/)
    .map((bloc) => normaliserTexte(bloc))
    .filter(Boolean);

  const chunks: Chunk[] = [];
  const maxChars = 1400;
  let tampon = '';
  let chunkOrdre = 0;

  const pousserChunk = () => {
    const contenuSection = normaliserTexte(tampon);
    if (!contenuSection) return;

    const prefixe = construirePrefixeChunk(document, section);
    const contenuFinal = `${prefixe}\n\n${contenuSection}`;
    const idBase = `${document.slug}-${sectionOrdre}-${chunkOrdre}`;
    const hash = createHash('sha1')
      .update(contenuFinal)
      .digest('hex')
      .slice(0, 10);

    chunks.push({
      id: `${idBase}-${hash}`,
      titre:
        chunkOrdre === 0
          ? `${document.titre} - ${section.titre}`
          : `${document.titre} - ${section.titre} - partie ${chunkOrdre + 1}`,
      contenu: contenuFinal,
      sectionTitre: section.titre,
      sectionOrdre,
      chunkOrdre,
      documentSlug: document.slug,
      sourceId: document.id,
      sourceNom: document.titre,
      sourceType: document.sourceType,
      sourceCategorie: document.categorie,
      sourceAutorite: document.autorite,
      sourceUrl: document.urlPrincipale ?? '',
      sourceModeAcces: document.modeAcces,
      sourcePeriodiciteMiseAJour: document.periodiciteMiseAJour,
      sourceOfficielle: document.officiel,
      sourcePriorite: document.priorite,
      tagsSource: document.tags,
      sourceDocument: path.basename(document.cheminAbsolu),
      sourcePath: document.cheminRelatif,
      corpusNamespace: document.namespaceCorpus,
      corpusVersion: document.versionCorpus,
    });
    tampon = '';
    chunkOrdre += 1;
  };

  for (const morceau of morceaux) {
    const candidat = tampon ? `${tampon}\n\n${morceau}` : morceau;
    if (candidat.length > maxChars && tampon) {
      pousserChunk();
      tampon = morceau;
      continue;
    }

    if (morceau.length > maxChars) {
      const phrases = morceau.split(/(?<=[.!?])\s+/);
      for (const phrase of phrases) {
        const bloc = tampon ? `${tampon} ${phrase}` : phrase;
        if (bloc.length > maxChars && tampon) {
          pousserChunk();
          tampon = phrase;
        } else {
          tampon = bloc;
        }
      }
      continue;
    }

    tampon = candidat;
  }

  pousserChunk();
  return chunks;
}

async function chargerChunksDocument(document: DocumentSource): Promise<Chunk[]> {
  const contenu = await fs.readFile(document.cheminAbsolu, 'utf8');
  const sections = extraireSections(contenu);
  return sections.flatMap((section, index) =>
    decouperSection(section, index, document),
  );
}

async function genererEmbeddings(chunks: Chunk[]): Promise<ChunkAvecEmbedding[]> {
  const tailleLot = 20;
  const chunksAvecEmbeddings: ChunkAvecEmbedding[] = [];

  for (let index = 0; index < chunks.length; index += tailleLot) {
    const lot = chunks.slice(index, index + tailleLot);
    console.log(
      `Génération des embeddings Vertex AI pour les chunks ${index + 1} à ${index + lot.length}/${chunks.length}...`,
    );

    const embeddings = await embedMany({
      embedder: embeddingModel,
      content: lot.map((chunk) => chunk.contenu),
      options: {
        taskType: embeddingTaskDocument,
      },
    });

    embeddings.forEach((item, lotIndex) => {
      const chunk = lot[lotIndex];
      if (!chunk) {
        return;
      }

      chunksAvecEmbeddings.push({
        ...chunk,
        embedding: item.embedding,
      });
    });
  }

  return chunksAvecEmbeddings;
}

async function supprimerDocumentsSnapshot(
  snapshot: admin.firestore.QuerySnapshot<admin.firestore.DocumentData>,
): Promise<number> {
  if (snapshot.empty) {
    return 0;
  }

  let compteur = 0;
  let batch = db.batch();
  let tailleBatch = 0;

  for (const document of snapshot.docs) {
    batch.delete(document.ref);
    compteur += 1;
    tailleBatch += 1;

    if (tailleBatch >= 400) {
      await batch.commit();
      batch = db.batch();
      tailleBatch = 0;
    }
  }

  if (tailleBatch > 0) {
    await batch.commit();
  }

  return compteur;
}

async function supprimerVersionsPrecedentes(
  documents: DocumentSource[],
): Promise<number> {
  const cibles = new Map<string, Set<string>>();

  for (const document of documents) {
    const slugs = cibles.get(document.collectionFirestore) ?? new Set<string>();
    slugs.add(document.slug);
    cibles.set(document.collectionFirestore, slugs);
  }

  let totalSupprime = 0;
  for (const [collection, slugs] of cibles.entries()) {
    for (const slug of slugs) {
      const snapshot = await db
        .collection(collection)
        .where('documentSlug', '==', slug)
        .get();
      totalSupprime += await supprimerDocumentsSnapshot(snapshot);
    }
  }

  return totalSupprime;
}

async function publierChunks(chunks: ChunkAvecEmbedding[]): Promise<void> {
  const chunksParCollection = new Map<string, ChunkAvecEmbedding[]>();

  for (const chunk of chunks) {
    const collection = chunk.corpusNamespace
      ? collectionParDefaut
      : collectionParDefaut;
    const items = chunksParCollection.get(collection) ?? [];
    items.push(chunk);
    chunksParCollection.set(collection, items);
  }

  for (const [collection, items] of chunksParCollection.entries()) {
    let batch = db.batch();
    let tailleBatch = 0;

    for (const chunk of items) {
      console.log(`Publication du chunk "${chunk.titre}"...`);
      const ref = db.collection(collection).doc(chunk.id);
      batch.set(ref, {
        titre: chunk.titre,
        contenu: chunk.contenu,
        sourceDocument: chunk.sourceDocument,
        sourcePath: chunk.sourcePath,
        sourceId: chunk.sourceId,
        sourceNom: chunk.sourceNom,
        sourceType: chunk.sourceType,
        sourceCategorie: chunk.sourceCategorie,
        sourceAutorite: chunk.sourceAutorite,
        sourceUrl: chunk.sourceUrl,
        sourceModeAcces: chunk.sourceModeAcces,
        sourcePeriodiciteMiseAJour: chunk.sourcePeriodiciteMiseAJour,
        sourceOfficielle: chunk.sourceOfficielle,
        sourcePriorite: chunk.sourcePriorite,
        tagsSource: chunk.tagsSource,
        documentSlug: chunk.documentSlug,
        corpusNamespace: chunk.corpusNamespace,
        corpusVersion: chunk.corpusVersion,
        sectionTitre: chunk.sectionTitre,
        sectionOrdre: chunk.sectionOrdre,
        chunkOrdre: chunk.chunkOrdre,
        statut: 'actif',
        indexationStatut: 'indexe',
        embeddingModele: embeddingModel.name,
        embeddingDimension: chunk.embedding.length,
        embeddingTache: embeddingTaskDocument,
        [vectorFieldName]: admin.firestore.FieldValue.vector(chunk.embedding),
        dateAjout: admin.firestore.FieldValue.serverTimestamp(),
        dateMiseAJour: admin.firestore.FieldValue.serverTimestamp(),
      });

      tailleBatch += 1;
      if (tailleBatch >= 400) {
        await batch.commit();
        batch = db.batch();
        tailleBatch = 0;
      }
    }

    if (tailleBatch > 0) {
      await batch.commit();
    }
  }
}

function extraireVecteur(valeur: unknown): number[] {
  if (Array.isArray(valeur)) {
    return valeur.map((item) => Number(item));
  }

  if (
    valeur &&
    typeof valeur === 'object' &&
    'toArray' in valeur &&
    typeof valeur.toArray === 'function'
  ) {
    return valeur.toArray().map((item: number) => Number(item));
  }

  return [];
}

function extraireCommandeCreationIndex(erreur: unknown): string | null {
  if (!erreur || typeof erreur !== 'object' || !('details' in erreur)) {
    return null;
  }

  const details = String(erreur.details ?? '');
  const match = details.match(/gcloud firestore indexes composite create .+$/);
  return match?.[0] ?? null;
}

async function verifierPublication(
  documents: DocumentSource[],
  nombreAttendu: number,
): Promise<void> {
  const collection = documents[0]?.collectionFirestore ?? collectionParDefaut;
  const collectionRef = db.collection(collection);

  let totalTrouve = 0;
  let premierDocument:
    | admin.firestore.QueryDocumentSnapshot<admin.firestore.DocumentData>
    | undefined;

  for (const document of documents) {
    const snapshot = await collectionRef
      .where('documentSlug', '==', document.slug)
      .get();

    totalTrouve += snapshot.size;

    const premierDuLot = snapshot.docs
      .slice()
      .sort((a, b) => {
        const sectionA = Number(a.get('sectionOrdre') ?? 0);
        const sectionB = Number(b.get('sectionOrdre') ?? 0);
        if (sectionA !== sectionB) return sectionA - sectionB;
        return Number(a.get('chunkOrdre') ?? 0) - Number(b.get('chunkOrdre') ?? 0);
      })[0];

    if (!premierDocument && premierDuLot) {
      premierDocument = premierDuLot;
    }
  }

  if (totalTrouve !== nombreAttendu) {
    throw new Error(
      `Vérification KO: ${totalTrouve} documents trouvés dans ${collection}, ${nombreAttendu} attendus.`,
    );
  }

  if (!premierDocument) {
    throw new Error(
      'Vérification KO: aucun document publié dans la collection vectorielle.',
    );
  }

  const embedding = extraireVecteur(premierDocument.get(vectorFieldName));
  if (embedding.length !== embeddingDimensions) {
    throw new Error(
      `Vérification KO: embedding de dimension ${embedding.length}, ${embeddingDimensions} attendue.`,
    );
  }

  const requeteVerification = `source fiscale officielle ${premierDocument.get('sourceNom') ?? ''}`;
  const embeddingRequete = await embed({
    embedder: embeddingModel,
    content: requeteVerification,
    options: {
      taskType: embeddingTaskQuery,
    },
  });

  console.log(
    `✅ Vérification structurelle OK: ${totalTrouve} documents publiés dans ${collection}.`,
  );

  try {
    const resultats = await collectionRef
      .findNearest({
        vectorField: vectorFieldName,
        queryVector: embeddingRequete,
        limit: 3,
        distanceMeasure: 'COSINE',
        distanceResultField: 'distance',
      })
      .get();

    if (resultats.empty) {
      throw new Error(
        `Vérification KO: aucune similarité retournée pour la requête "${requeteVerification}".`,
      );
    }

    console.log(
      `✅ Vérification vectorielle OK: ${resultats.size} voisins trouvés pour "${requeteVerification}".`,
    );
    resultats.docs.forEach((doc, index) => {
      console.log(
        `   #${index + 1} ${doc.id} | titre="${doc.get('titre')}" | distance=${doc.get('distance')}`,
      );
    });
  } catch (erreur) {
    const commandeIndex = extraireCommandeCreationIndex(erreur);
    if (commandeIndex) {
      console.warn(
        `⚠️ Vérification vectorielle différée: l’index KNN Firestore manque encore pour ${collection}.`,
      );
      console.warn(`Commande suggérée: ${commandeIndex}`);
      return;
    }

    throw erreur;
  }
}

async function seedDatabase() {
  console.log('Démarrage de l’ingestion du corpus RAG vers Firestore...');
  console.log(`Projet Firebase: ${projectId}`);
  console.log(`Vertex AI location: ${configurationVertexAi.location}`);

  const documents = await resoudreDocumentsSource();
  console.log(`Documents source détectés: ${documents.length}`);
  documents.forEach((document) => {
    console.log(
      ` - ${document.titre} | slug=${document.slug} | officiel=${document.officiel} | chemin=${document.cheminAbsolu}`,
    );
  });

  const lots = await Promise.all(
    documents.map(async (document) => {
      const chunks = await chargerChunksDocument(document);
      console.log(`Chunks générés pour ${document.slug}: ${chunks.length}`);
      return chunks;
    }),
  );

  const chunks = lots.flat();
  if (chunks.length === 0) {
    throw new Error('Aucun chunk généré: l’ingestion est impossible.');
  }

  const chunksAvecEmbeddings = await genererEmbeddings(chunks);
  console.log(
    `Embeddings générés: ${chunksAvecEmbeddings.length} vecteurs (${embeddingDimensions} dimensions attendues).`,
  );

  const supprimes = await supprimerVersionsPrecedentes(documents);
  if (supprimes > 0) {
    console.log(`Ancienne version supprimée: ${supprimes} documents.`);
  }

  await publierChunks(chunksAvecEmbeddings);
  await verifierPublication(documents, chunksAvecEmbeddings.length);
  console.log(
    `🎉 Ingestion terminée: le corpus est publié dans ${documents[0]?.collectionFirestore ?? collectionParDefaut} avec des embeddings Vertex AI.`,
  );
}

seedDatabase()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Script failed:', err);
    process.exit(1);
  });
