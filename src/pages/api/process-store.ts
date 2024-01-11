import type { APIRoute } from "astro";
import { randomUUID } from 'crypto';
import proposalTemplates from '@utils/proposalTemplates';

import { parseProcessRawCookie } from '@utils/parseProcessCookie';


export const POST: APIRoute = async ({ request }) => {
  const formData = await request.formData();
  const step = Number(formData.get('step') || 1);
  const nextStep = step + 1;
  let processCookieObject = parseProcessRawCookie(request.headers.get('cookie'));
  processCookieObject.create = 'false';
  const referer = request.headers.get('referer') as string;

  if (step === 1) {
    try {
      Object.assign(processCookieObject, {
        step: nextStep,
        weighting: formData.get('weighting'),
        title: formData.get('topicQuestion'),
        nojsdescription: formData.get('nojsdescription'),
        quillopsdescription: formData.get('quillopsdescription'),
        phase: formData.get('phase')
      });

      const headers = new Headers({
        'Set-Cookie': `process=${encodeURIComponent(JSON.stringify(processCookieObject))}; Path=/; HttpOnly; SameSite=Strict`,
        'Content-Type': 'application/json',
        'Location': referer
      });

      return new Response(null, { status: 303, headers: headers });

    } catch (error) {
      console.error("Error:", error);
      return new Response(null, { status: 303, headers: { 'Location': '/create' } });
    }
  } else if (step === 2) {
    const phase = processCookieObject.phase;

    const currentDate = new Date().getTime();
    let startProposalDate = formData.get('start-date-picker-proposal') ? new Date(formData.get('start-date-picker-proposal') as string).getTime() : processCookieObject.startProposalDate || currentDate;
    let endProposalDate = formData.get('end-date-picker-proposal') ? new Date(formData.get('end-date-picker-proposal') as string).getTime() : processCookieObject.endProposalDate || (startProposalDate + 3600000); // +1 hour
    let startVotingDate = formData.get('start-date-picker-voting') ? new Date(formData.get('start-date-picker-voting') as string).getTime() : processCookieObject.startVotingDate || endProposalDate;
    let endVotingDate = formData.get('end-date-picker-voting') ? new Date(formData.get('end-date-picker-voting') as string).getTime() : processCookieObject.endVotingDate || (startVotingDate + 3600000); // +1 hour

    if (endProposalDate <= startProposalDate) {
      endProposalDate = startProposalDate + 60000;
    }

    if (startVotingDate < endProposalDate) {
      startVotingDate = endProposalDate;
    }

    if (endVotingDate <= startVotingDate) {
        endVotingDate = startVotingDate + 60000;
    }

    if (phase === 'full') {
      try {
        processCookieObject.startProposalDate = startProposalDate;
        processCookieObject.endProposalDate = endProposalDate;
        processCookieObject.startVotingDate = startVotingDate;
        processCookieObject.endVotingDate = endVotingDate;

        if (!formData.get('nojsSubmission')) {
          processCookieObject.step = nextStep.toString();
        }

        const headers = new Headers({
          'Set-Cookie': `process=${encodeURIComponent(JSON.stringify(processCookieObject))}; Path=/; HttpOnly; SameSite=Strict`,
          'Content-Type': 'application/json',
          'Location': referer
        });

        return new Response(null, { status: 303, headers: headers });
      } catch (error) {
        console.error("Error:", error);
        return new Response(null, { status: 303, headers: { 'Location': referer} });
      }
    } else if (phase === 'voting') {
      try {
        processCookieObject.startVotingDate = startVotingDate;
        processCookieObject.endVotingDate = endVotingDate;
        console.log(formData.get('nojsSubmission'));
        if (formData.get('nojsSubmission')) {
          console.log('hi')

          console.log(formData.has('title'));
          if (formData.has('title')) {
            let title = formData.get('title') as string;
            let description = formData.get('description') as string;
            if (formData.has('tmpl')) {
              const tmpl = Number(formData.get('tmpl') as string);
              title = proposalTemplates[tmpl].title;
              description = proposalTemplates[tmpl].description.ops[0].insert;

              console.log(tmpl, title)

            }
            const proposalId = randomUUID(); 
            processCookieObject.proposals = processCookieObject.proposals || [];
            processCookieObject.proposals.push({ id: proposalId, title, description, createdAt: new Date().getTime() });
          }
        } else {
          processCookieObject.step = nextStep.toString();
        }

        const headers = new Headers({
          'Set-Cookie': `process=${encodeURIComponent(JSON.stringify(processCookieObject))}; Path=/; HttpOnly; SameSite=Strict`,
          'Content-Type': 'application/json',
          'Location': referer
        });

        return new Response(null, { status: 303, headers: headers });
      } catch (error) {
        console.error("Error:", error);
        return new Response(null, { status: 303, headers: { 'Location': referer} });
      }
    } else {
      return new Response(null, { status: 303, headers: { 'Location': referer } });
    }
  }
  console.error("Invalid Step");

  return new Response(null, { status: 303, headers: { 'Location': referer } });

};
