"use client"

import { useState, useEffect } from "react"

interface CountdownTimerProps {
  targetDate: string
  title: string
}

export default function CountdownTimer({ targetDate, title }: CountdownTimerProps) {
  const [timeLeft, setTimeLeft] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  })

  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date().getTime()
      const target = new Date(targetDate).getTime()
      const difference = target - now

      if (difference > 0) {
        setTimeLeft({
          days: Math.floor(difference / (1000 * 60 * 60 * 24)),
          hours: Math.floor((difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)),
          minutes: Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60)),
          seconds: Math.floor((difference % (1000 * 60)) / 1000),
        })
      } else {
        setTimeLeft({ days: 0, hours: 0, minutes: 0, seconds: 0 })
      }
    }, 1000)

    return () => clearInterval(timer)
  }, [targetDate])

  return (
    <div className="bg-gradient-to-r from-yellow-400 to-yellow-500 dark:from-yellow-500 dark:to-yellow-600 rounded-lg p-6 text-center">
      <h3 className="text-lg font-semibold text-yellow-900 dark:text-yellow-100 mb-2">🎬 Estreia em breve!</h3>
      <p className="text-yellow-800 dark:text-yellow-200 mb-4 font-medium">{title}</p>

      <div className="grid grid-cols-4 gap-4 max-w-md mx-auto">
        <div className="bg-white dark:bg-gray-800 rounded-lg p-3">
          <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">{timeLeft.days}</div>
          <div className="text-xs text-gray-600 dark:text-gray-400">Dias</div>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-lg p-3">
          <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">{timeLeft.hours}</div>
          <div className="text-xs text-gray-600 dark:text-gray-400">Horas</div>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-lg p-3">
          <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">{timeLeft.minutes}</div>
          <div className="text-xs text-gray-600 dark:text-gray-400">Min</div>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-lg p-3">
          <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">{timeLeft.seconds}</div>
          <div className="text-xs text-gray-600 dark:text-gray-400">Seg</div>
        </div>
      </div>
    </div>
  )
}
