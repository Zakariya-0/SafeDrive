package com.safedrive.service;

import com.safedrive.dao.AccidentDAO;
import com.safedrive.dao.UserDAO;
import com.safedrive.dao.VehicleDAO;
import com.safedrive.model.Accident;
import com.safedrive.model.AccidentSeverity;
import com.safedrive.model.AccidentStatus;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public class AccidentService {

    private final AccidentDAO accidentDAO = new AccidentDAO();
    private final UserDAO     userDAO     = new UserDAO();
    private final VehicleDAO  vehicleDAO  = new VehicleDAO();

    public Accident declareAccident(Long driverId, Long vehicleId, LocalDate date,
                                    String location, String description,
                                    AccidentSeverity severity,
                                    Double latitude, Double longitude) {
        Accident a = new Accident();
        a.setDriver(userDAO.findById(driverId)
                .orElseThrow(() -> new IllegalArgumentException("Driver not found: " + driverId)));
        a.setVehicle(vehicleDAO.findById(vehicleId)
                .orElseThrow(() -> new IllegalArgumentException("Vehicle not found: " + vehicleId)));
        a.setDate(date);
        a.setLocation(location);
        a.setDescription(description);
        a.setSeverity(severity);
        a.setStatus(AccidentStatus.DECLARED);
        a.setLatitude(latitude);
        a.setLongitude(longitude);
        // accidentDAO.save() returns a merged entity whose driver/vehicle are lazy proxies
        // (session already closed). 'a' still holds the real, fully-loaded User and Vehicle
        // objects fetched above, so we return 'a' after copying the generated PK.
        Accident persisted = accidentDAO.save(a);
        a.setId(persisted.getId());
        return a;
    }

    public Accident updateStatus(Long accidentId, AccidentStatus newStatus) {
        Accident a = accidentDAO.findById(accidentId)
                .orElseThrow(() -> new IllegalArgumentException("Accident not found"));
        a.setStatus(newStatus);
        return accidentDAO.save(a);
    }

    public Accident updateSeverity(Long accidentId, AccidentSeverity newSeverity) {
        Accident a = accidentDAO.findById(accidentId)
                .orElseThrow(() -> new IllegalArgumentException("Accident not found"));
        a.setSeverity(newSeverity);
        a.setGraviteManuelle(true);
        return accidentDAO.save(a);
    }

    public Accident updateAIResult(Long accidentId, String aiSeverity, Double confidence) {
        Accident a = accidentDAO.findById(accidentId)
                .orElseThrow(() -> new IllegalArgumentException("Accident not found"));
        a.setAiSeverity(aiSeverity);
        a.setAiConfidence(confidence);
        return accidentDAO.save(a);
    }

    public void deleteAccident(Long id)                           { accidentDAO.delete(id); }
    public Optional<Accident> findById(Long id)                   { return accidentDAO.findById(id); }
    public Optional<Accident> findByIdWithDetails(Long id)        { return accidentDAO.findByIdWithDetails(id); }
    public List<Accident> getAllAccidents()                        { return accidentDAO.findAll(); }
    public List<Accident> getAccidentsByDriver(Long driverId)     { return accidentDAO.findByDriverId(driverId); }
    public List<Accident> getRecentAccidents(int limit)           { return accidentDAO.findRecent(limit); }
    public long countTotal()                                       { return accidentDAO.count(); }
    public long countByStatus(AccidentStatus s)                    { return accidentDAO.countByStatus(s); }
}
