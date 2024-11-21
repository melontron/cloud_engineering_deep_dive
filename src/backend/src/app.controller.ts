import { Controller, Get, HttpCode, Header } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('v1')
  getVersion(): object {
    return {
      version: '1.0.0',
      description: 'aca cloud engineering deep dive api',
    };
  }

  @Get('health')
  @Header('Cache-Control', 'no-cache, no-store, must-revalidate')
  @Header('Pragma', 'no-cache')
  @Header('Expires', '0')
  @HttpCode(200)
  getHealth(): object {
    return {
      status: 'ok',
    };
  }

  @Get('run')
  @Header('Cache-Control', 'no-cache, no-store, must-revalidate')
  @Header('Pragma', 'no-cache')
  @Header('Expires', '0')
  consumeCpu(): object {
    const startTime = Date.now();
    const duration = 1000;

    // Function to check if a number is prime
    const isPrime = (num: number): boolean => {
      for (let i = 2; i <= Math.sqrt(num); i++) {
        if (num % i === 0) {
          return false;
        }
      }
      return num > 1;
    };

    // Generate CPU load by finding prime numbers
    let count = 0;
    let num = 2;
    while (Date.now() - startTime < duration) {
      if (isPrime(num)) {
        count++;
      }
      num++;
    }

    return {
      status: 'ok',
      message: `Found ${count} prime numbers in ${duration} milliseconds`,
    };
  }
}
