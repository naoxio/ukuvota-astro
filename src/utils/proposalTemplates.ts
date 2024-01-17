import { Translator } from '@utils/i18n.js';

export default async function getProposalTemplates(locale: string) {
  const translator = new Translator(locale); 
  await translator.init();

  return [
    {
      title: translator.t('proposal.zero.title'),
      description: {
        ops: [
          { insert: translator.t('proposal.zero.description') },
        ]
      }
    },
    {
      title: translator.t('proposal.one.title'),
      description: {
        ops: [
          { insert: translator.t('proposal.one.description') },
        ]
      }
    },
  ];
}