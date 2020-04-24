using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using SecondChanceParts.Api.Models;

namespace SecondChanceparts.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PartsController : ControllerBase
    {

        private readonly SecondChanceParts.Api.Data.SecondChancePartsContext _context;
        private readonly ILogger<PartsController> _logger;

        public PartsController(SecondChanceParts.Api.Data.SecondChancePartsContext context,ILogger<PartsController> logger)
        {
            _context = context;
            _logger = logger;
        }
        
      
        [HttpGet]
        public async Task<IActionResult> GetPartsAsync(){

            var parts = await _context.Parts.ToListAsync();

            return Ok(parts);

        }



    }
}
