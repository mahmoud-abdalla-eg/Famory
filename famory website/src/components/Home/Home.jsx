import React from 'react'
import HeroSection from './HeroSection'
import FeaturesSection from './FeaturesSection'
import AboutUsSection from './AboutUsSection'
import FAQSection from './FAQSection'
import CTASection from './CTASection'

export default function Home({ t, darkMode }) {
  return (
    <React.Fragment>
      <HeroSection t={t} darkMode={darkMode} />
      <FeaturesSection t={t} darkMode={darkMode} />
      <AboutUsSection t={t} darkMode={darkMode} />
      <FAQSection t={t} darkMode={darkMode} />
      <CTASection t={t} darkMode={darkMode} />
    </React.Fragment>
  )
}
