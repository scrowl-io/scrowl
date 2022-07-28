import React from 'react';
import { Accordion, AccordionDefaultProps } from '@owlui/lib';

export const Outline = ({ items }: AccordionDefaultProps) => {
  return <Accordion items={items} flush alwaysOpen />;
};

export default {
  Outline,
};
